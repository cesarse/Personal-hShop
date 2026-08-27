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

    private enum DownloadError: Error {
        case unavailable
    }

    private init() {
    }

    private func renderIndexPage() {
        html {
            body {
                let ciaFiles: [String]
                do {
                    ciaFiles = try bookmarkStore.withSecurityScopedFolderAccess
                    { folderURL in
                        let allFiles = try FileManager.default
                            .contentsOfDirectory(atPath: folderURL.path)
                        return
                            allFiles
                            .filter { $0.lowercased().hasSuffix(".cia") }
                            .sorted {
                                $0.localizedStandardCompare($1)
                                    == .orderedAscending
                            }
                    }
                } catch {
                    print("debug: failed to list files: \(error)")
                    ciaFiles = []
                }
                print("debug: ", ciaFiles)
                if ciaFiles.isEmpty {
                    h1 {
                        inner = "No .cia files found"
                    }
                } else {
                    ul {
                        for ciaFile in ciaFiles {
                            li {
                                a {
                                    href =
                                        Webserver.downloadPrefix + "/"
                                        + Webserver.pathEncoded(ciaFile)
                                    inner = Webserver.htmlEscaped(ciaFile)
                                }
                            }
                        }
                    }
                }
            }
        }
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

    /// Quoted form for simple clients, RFC 5987 form for everything else.
    private static func contentDisposition(for fileName: String) -> String {
        let quoted = fileName.replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\\", with: "")
        return
            "attachment; filename=\"\(quoted)\"; filename*=UTF-8''\(pathEncoded(fileName))"
    }

    func start() throws {
        if isRunning { return }
        server["/"] = scopes {

            self.renderIndexPage()

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
