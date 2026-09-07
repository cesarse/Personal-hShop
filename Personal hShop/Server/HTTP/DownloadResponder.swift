import Foundation
import Swifter

/// Answers a download request with the file it names.
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
            let file = try DownloadableFile(named: fileName, in: bookmarkStore)
            return .raw(
                200,
                "OK",
                DownloadHeaders.serving(fileName, ofSize: file.size),
                DownloadResponder.stream(file)
            )
        } catch {
            print("debug: failed to serve \(fileName): \(error)")
            return .notFound
        }
    }

    private static func stream(
        _ file: DownloadableFile
    ) -> (HttpResponseBodyWriter) throws -> Void {
        { writer in
            defer { try? file.handle.close() }
            while let chunk = try file.handle.read(upToCount: chunkSize),
                !chunk.isEmpty
            {
                try writer.write(chunk)
            }
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
}
