import CoreImage.CIFilterBuiltins
import Foundation
import SwiftUI
import Swifter

class Webserver: ObservableObject {

    @AppStorage("port") private var port: Int = 1234
    @AppStorage("openPage") private var openPage: Bool = false

    static let instance = Webserver()
    @Published var isRunning: Bool = false

    let server = HttpServer()
    private let bookmarkStore = BookmarkStore()

    private static let downloadPrefix = "/files"
    private static let chunkSize = 512 * 1024

    /// Characters that may appear unescaped in a single URL path component.
    /// `urlPathAllowed` permits "/", which would let a file name span
    /// several path segments, so it is removed here.
    private static let pathComponentAllowed: CharacterSet = {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/")
        return allowed
    }()

    /// Reused across requests: building a `CIContext` is expensive.
    private static let ciContext = CIContext()

    /// Titles read out of the CIA files, keyed by name, size and mtime.
    /// Parsing scans a large part of each file, and the index page is
    /// rendered afresh on every request, so the result has to be kept.
    private var titleCache: [String: String] = [:]
    private let titleCacheLock = NSLock()

    private enum DownloadError: Error {
        case unavailable
    }

    private init() {
    }

    /// A `.cia` in the shared folder, with the name to show for it.
    private struct Game {
        let fileName: String
        let displayName: String
    }

    private func listGames() -> [Game] {
        do {
            return try bookmarkStore.withSecurityScopedFolderAccess {
                folderURL in
                let allFiles = try FileManager.default
                    .contentsOfDirectory(atPath: folderURL.path)
                return
                    allFiles
                    .filter { $0.lowercased().hasSuffix(".cia") }
                    .sorted {
                        $0.localizedStandardCompare($1) == .orderedAscending
                    }
                    .map { fileName in
                        Game(
                            fileName: fileName,
                            displayName: self.displayName(
                                for: fileName,
                                in: folderURL
                            )
                        )
                    }
            }
        } catch {
            print("debug: failed to list files: \(error)")
            return []
        }
    }

    /// The game's own title when the CIA yields one, otherwise the file name.
    ///
    /// An encrypted CIA with no meta section carries no readable title at
    /// all, so falling back to the file name is an ordinary outcome here
    /// rather than a failure worth surfacing on the page.
    private func displayName(for fileName: String, in folderURL: URL) -> String
    {
        let fileURL = folderURL.appendingPathComponent(fileName)
        let attributes = try? FileManager.default.attributesOfItem(
            atPath: fileURL.path
        )
        let size = (attributes?[.size] as? NSNumber)?.int64Value ?? 0
        let modified =
            (attributes?[.modificationDate] as? Date)?
            .timeIntervalSince1970 ?? 0
        let key = "\(fileName)|\(size)|\(modified)"

        titleCacheLock.lock()
        let cached = titleCache[key]
        titleCacheLock.unlock()
        if let cached { return cached }

        // The title inside the CIA is authoritative; the file name is the
        // fallback, and the raw name the last resort.
        var title = Webserver.titleFromFileName(fileName) ?? fileName
        do {
            let parsed = try CIAParser.extractEnglishTitle(from: fileURL)
            let cleaned = Webserver.sanitizedTitle(parsed)
            if !cleaned.isEmpty { title = cleaned }
        } catch {
            print("debug: no title in \(fileName): \(error)")
        }

        titleCacheLock.lock()
        titleCache[key] = title
        titleCacheLock.unlock()
        return title
    }

    /// Recovers the game name from the usual release naming convention:
    /// "<16-hex title id> <name> (<product code>) (v<version>) (<region>)".
    ///
    /// Plan B for the common case. An encrypted CIA with no meta section
    /// carries no readable title anywhere in its bytes, and that describes
    /// most of a real library, so the file name is all that is left.
    private static func titleFromFileName(_ fileName: String) -> String? {
        var name = fileName

        // Trailing ".cia" and the scene tag before it ("legit",
        // "piratelegit", "standard") are not part of the name.
        if let dotCIA = name.range(
            of: ".cia",
            options: [.backwards, .caseInsensitive]
        ), dotCIA.upperBound == name.endIndex {
            name = String(name[..<dotCIA.lowerBound])
        }

        // A 16-digit hex title ID leads the name when present.
        if name.prefix(16).count == 16,
            name.prefix(16).allSatisfy(\.isHexDigit)
        {
            name = String(name.dropFirst(16))
        }
        name = name.trimmingCharacters(in: .whitespaces)

        if let cut = firstMetadataGroup(in: name) {
            name = String(name[..<cut])
        }

        name = name.trimmingCharacters(
            in: CharacterSet(charactersIn: " -_.").union(
                .whitespacesAndNewlines
            )
        )
        return name.isEmpty ? nil : name
    }

    /// Where the release detail starts, i.e. the first "(...)" that reads as
    /// metadata rather than as part of the title itself.
    private static func firstMetadataGroup(in name: String) -> String.Index? {
        var searchFrom = name.startIndex
        while let open = name[searchFrom...].firstIndex(of: "("),
            let close = name[open...].firstIndex(of: ")")
        {
            let group = String(name[name.index(after: open)..<close])
            if isReleaseMetadata(group) { return open }
            searchFrom = name.index(after: close)
        }
        return nil
    }

    private static func isReleaseMetadata(_ group: String) -> Bool {
        let upper = group.uppercased()
        // Product code, e.g. "CTR-P-BMAP" for 3DS or "KTR-..." for New 3DS.
        if upper.hasPrefix("CTR-") || upper.hasPrefix("KTR-") { return true }
        // Version, e.g. "v0.1.0".
        if upper.hasPrefix("V"), group.count > 1,
            group.dropFirst().allSatisfy({ $0.isNumber || $0 == "." })
        {
            return true
        }
        // Region or language, e.g. "E", "W", "USA", "JPN".
        if !upper.isEmpty, upper.count <= 3, upper.allSatisfy(\.isLetter) {
            return true
        }
        return false
    }

    /// SMDH short descriptions are NUL-padded to a fixed width and are free
    /// to wrap onto a second line, neither of which belongs in a caption.
    private static func sanitizedTitle(_ title: String) -> String {
        String(title.prefix { $0 != "\0" })
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func renderIndexPage(_ request: HttpRequest) -> HttpResponse {
        // The 3DS resolves whatever the QR code contains over the network, so
        // the codes have to carry an absolute URL this Mac answers on. A
        // relative path or "localhost" would be useless to the console.
        let baseURL = Webserver.baseURL(for: request, port: port)
        let games = listGames()
        print("debug: ", games.map(\.fileName))

        return scopes {
            html {
                head {
                    meta {
                        charset = "utf-8"
                    }
                    meta {
                        name = "viewport"
                        content = "width=device-width, initial-scale=1"
                    }
                    title {
                        inner = "Personal hShop"
                    }
                    style {
                        inner = Webserver.stylesheet
                    }
                }
                body {
                    h1 {
                        inner = "Personal hShop"
                    }
                    if games.isEmpty {
                        p {
                            classs = "hint"
                            inner = "No .cia files found"
                        }
                    } else {
                        p {
                            classs = "hint"
                            inner =
                                "In FBI, choose Remote Install &rarr; Scan QR "
                                + "Code, then point the 3DS at a code below. "
                                + "Serving from "
                                + Webserver.htmlEscaped(baseURL) + "."
                        }
                        div {
                            classs = "grid"
                            for game in games {
                                let target =
                                    baseURL + Webserver.downloadPrefix + "/"
                                    + Webserver.pathEncoded(game.fileName)
                                figure {
                                    classs = "card"
                                    div {
                                        classs = "qr"
                                        if let qr = Webserver.qrCodeDataURI(
                                            for: target
                                        ) {
                                            img {
                                                src = qr
                                                alt = Webserver.htmlEscaped(
                                                    game.displayName
                                                )
                                            }
                                        } else {
                                            span {
                                                classs = "qr-failed"
                                                inner =
                                                    "QR code unavailable"
                                            }
                                        }
                                    }
                                    figcaption {
                                        inner = Webserver.htmlEscaped(
                                            game.displayName
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }(request)
    }

    /// Streams a single `.cia` file out of the bookmarked folder.
    private func handleDownload(_ request: HttpRequest) -> HttpResponse {
        // Swifter's router already percent-decodes each path segment before it
        // reaches `params`, so the name arrives ready to use here.
        guard let fileName = request.params[":name"],
            Webserver.isServableFileName(fileName)
        else {
            return .notFound
        }

        do {
            let (file, fileSize) =
                try bookmarkStore.withSecurityScopedFolderAccess {
                    folderURL -> (FileHandle, UInt64) in
                    let fileURL = folderURL.appendingPathComponent(fileName)

                    // Belt and braces: the resolved file has to sit directly
                    // inside the folder the user actually shared.
                    guard
                        fileURL.deletingLastPathComponent().standardizedFileURL
                            .path == folderURL.standardizedFileURL.path
                    else {
                        throw DownloadError.unavailable
                    }

                    let attributes = try FileManager.default.attributesOfItem(
                        atPath: fileURL.path
                    )
                    guard
                        attributes[.type] as? FileAttributeType == .typeRegular,
                        let fileSize = attributes[.size] as? UInt64
                    else {
                        throw DownloadError.unavailable
                    }

                    // The descriptor is opened while access is still granted,
                    // so it stays readable once the scope is released below
                    // and the body is streamed.
                    return (try FileHandle(forReadingFrom: fileURL), fileSize)
                }

            let headers = [
                "Content-Type": "application/octet-stream",
                "Content-Length": String(fileSize),
                "Content-Disposition": Webserver.contentDisposition(
                    for: fileName
                ),
                "Accept-Ranges": "none",
            ]

            return .raw(200, "OK", headers) { writer in
                defer { try? file.close() }
                while let chunk = try file.read(
                    upToCount: Webserver.chunkSize
                ), !chunk.isEmpty {
                    try writer.write(chunk)
                }
            }
        } catch {
            print("debug: failed to serve \(fileName): \(error)")
            return .notFound
        }
    }

    /// Rejects anything that is not a plain `.cia` file name, which also keeps
    /// path traversal and header injection out of the download handler.
    private static func isServableFileName(_ fileName: String) -> Bool {
        guard !fileName.isEmpty, fileName.utf8.count <= 255 else {
            return false
        }
        guard fileName != ".", fileName != ".." else { return false }
        guard !fileName.contains("/"), !fileName.contains("\\") else {
            return false
        }
        guard fileName.rangeOfCharacter(from: .controlCharacters) == nil else {
            return false
        }
        return fileName.lowercased().hasSuffix(".cia")
    }

    /// Renders `text` as a QR code and returns it as an inline `data:` URI.
    ///
    /// The bitmap is one pixel per module and the page scales it up with
    /// `image-rendering: pixelated`, which keeps the modules crisp while
    /// keeping the embedded image small.
    private static func qrCodeDataURI(for text: String) -> String? {
        guard let message = text.data(using: .utf8) else { return nil }

        let generator = CIFilter.qrCodeGenerator()
        generator.message = message
        // Lowest correction level keeps the module count down, which matters
        // for the 3DS camera: fewer, larger modules scan far more reliably
        // than a dense code, and a screen has no dirt to correct for.
        generator.correctionLevel = "L"

        guard let image = generator.outputImage,
            let cgImage = ciContext.createCGImage(image, from: image.extent)
        else {
            return nil
        }

        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        guard let png = bitmap.representation(using: .png, properties: [:])
        else {
            return nil
        }
        return "data:image/png;base64," + png.base64EncodedString()
    }

    /// The address the 3DS should call back on.
    ///
    /// A request that already arrived over the network proves which address
    /// reaches this Mac, so its `Host` wins — but only when it is a numeric
    /// address. FBI resolves neither "localhost" nor an mDNS ".local" name,
    /// so anything else falls back to a LAN address found here.
    private static func baseURL(for request: HttpRequest, port: Int) -> String {
        if let host = request.headers["host"],
            isRoutableIPv4(hostname(from: host))
        {
            return "http://" + host
        }
        if let address = lanAddress() {
            return "http://\(address):\(port)"
        }
        return "http://localhost:\(port)"
    }

    /// Strips the port from a `Host` header value, leaving bracketed IPv6
    /// literals and bare (colon-bearing) IPv6 addresses intact.
    private static func hostname(from host: String) -> String {
        if host.hasPrefix("[") {
            return String(host.dropFirst().prefix { $0 != "]" })
        }
        let parts = host.split(separator: ":", omittingEmptySubsequences: false)
        return parts.count == 2 ? String(parts[0]) : host
    }

    private static func isRoutableIPv4(_ name: String) -> Bool {
        var address = in_addr()
        guard name.withCString({ inet_pton(AF_INET, $0, &address) }) == 1 else {
            return false
        }
        // 127.0.0.0/8 means the page was opened on this Mac, which tells us
        // nothing about the address the console should use.
        return UInt32(bigEndian: address.s_addr) >> 24 != 127
    }

    /// First usable IPv4 address of an up, non-loopback interface.
    private static func lanAddress() -> String? {
        var head: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&head) == 0, let first = head else { return nil }
        defer { freeifaddrs(head) }

        var candidates: [(interface: String, address: String)] = []
        for pointer in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let flags = Int32(pointer.pointee.ifa_flags)
            guard flags & IFF_UP != 0, flags & IFF_LOOPBACK == 0,
                let address = pointer.pointee.ifa_addr,
                address.pointee.sa_family == UInt8(AF_INET)
            else {
                continue
            }

            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            guard
                getnameinfo(
                    address,
                    socklen_t(address.pointee.sa_len),
                    &host,
                    socklen_t(host.count),
                    nil,
                    0,
                    NI_NUMERICHOST
                ) == 0
            else {
                continue
            }

            candidates.append(
                (
                    String(cString: pointer.pointee.ifa_name),
                    String(cString: host)
                )
            )
        }

        // en0 is Wi-Fi or the built-in Ethernet on every Mac, so it is the
        // interface the 3DS is most likely to share a network with.
        return candidates.first { $0.interface == "en0" }?.address
            ?? candidates.first { $0.interface.hasPrefix("en") }?.address
            ?? candidates.first?.address
    }

    private static func pathEncoded(_ fileName: String) -> String {
        fileName.addingPercentEncoding(
            withAllowedCharacters: pathComponentAllowed)
            ?? fileName
    }

    private static func htmlEscaped(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    private static let stylesheet = """
        body {
                font: 15px -apple-system, BlinkMacSystemFont, sans-serif;
                margin: 0 auto;
                padding: 2rem 1.5rem 3rem;
                max-width: 1100px;
                color: #1c1c1e;
                background: #f5f5f7;
            }
            h1 { font-size: 1.5rem; margin: 0 0 .25rem; }
            .hint { margin: 0 0 2rem; color: #6b6b70; }
            .grid {
                display: grid;
                gap: 1.25rem;
                grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            }
            .card {
                margin: 0;
                padding: 1rem;
                border-radius: 12px;
                background: #fff;
                box-shadow: 0 1px 3px rgba(0, 0, 0, .12);
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: .75rem;
            }
            /* White padding around the code is the QR quiet zone; without it
               scanners struggle to find the symbol. */
            .qr {
                background: #fff;
                padding: 12px;
                line-height: 0;
            }
            .qr img {
                display: block;
                width: 208px;
                height: 208px;
                image-rendering: pixelated;
            }
            .qr-failed { color: #b00020; font-size: .85rem; }
            figcaption {
                font-size: .8rem;
                line-height: 1.35;
                text-align: center;
                word-break: break-word;
                color: #3a3a3c;
            }
        """

    /// Quoted form for simple clients, RFC 5987 form for everything else.
    private static func contentDisposition(for fileName: String) -> String {
        let quoted = fileName.replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\\", with: "")
        return
            "attachment; filename=\"\(quoted)\"; filename*=UTF-8''\(pathEncoded(fileName))"
    }

    func start() throws {
        if isRunning { return }
        server["/"] = { [weak self] request in
            self?.renderIndexPage(request) ?? .notFound
        }
        server["\(Webserver.downloadPrefix)/:name"] = { [weak self] request in
            self?.handleDownload(request) ?? .notFound
        }
        try server.start(UInt16(port), forceIPv4: true)
        print("debug: server started")
        isRunning = true
        if openPage, let url = URL(string: "http://localhost:\(port)") {
            NSWorkspace.shared.open(url)
        }
    }

    func stop() {
        if !isRunning { return }
        server.stop()
        print("debug: server stopped")
        isRunning = false
    }

}
