import Foundation
import Swifter

/// Streams a single `.cia` file out of the bookmarked folder.
struct DownloadResponder {

    private static let chunkSize = 512 * 1024

    private let bookmarkStore: BookmarkStore

    init(bookmarkStore: BookmarkStore = BookmarkStore()) {
        self.bookmarkStore = bookmarkStore
    }

    func respond(to request: HttpRequest) -> HttpResponse {
        // Swifter's router already percent-decodes each path segment before it
        // reaches `params`, so the name arrives ready to use here.
        guard let fileName = request.params[":name"],
            DownloadResponder.isServableFileName(fileName)
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
                "Content-Disposition": DownloadResponder.contentDisposition(
                    for: fileName
                ),
                "Accept-Ranges": "none",
            ]

            return .raw(200, "OK", headers) { writer in
                defer { try? file.close() }
                while let chunk = try file.read(
                    upToCount: DownloadResponder.chunkSize
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
    static func isServableFileName(_ fileName: String) -> Bool {
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

    /// Quoted form for simple clients, RFC 5987 form for everything else.
    static func contentDisposition(for fileName: String) -> String {
        let quoted = fileName.replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\\", with: "")
        return
            "attachment; filename=\"\(quoted)\"; filename*=UTF-8''\(DownloadRoute.encoded(fileName))"
    }
}
