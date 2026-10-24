import Foundation
import Hummingbird

/// Answers a download request with the file it names.
struct DownloadResponder {

    private static let chunkSize = 512 * 1024

    private let bookmarkStore: BookmarkStore

    init(bookmarkStore: BookmarkStore = BookmarkStore()) {
        self.bookmarkStore = bookmarkStore
    }

    /// `segment` is the path segment naming the file, still escaped.
    func respond(toSegment segment: String?) -> Response {
        guard let segment,
            let fileName = DownloadRoute.fileName(fromSegment: segment),
            DownloadResponder.isServableFileName(fileName)
        else {
            return Response(status: .notFound)
        }

        do {
            let file = try DownloadableFile(named: fileName, in: bookmarkStore)
            return Response(
                status: .ok,
                headers: DownloadHeaders.serving(fileName, ofSize: file.size),
                body: DownloadResponder.stream(file)
            )
        } catch {
            print("debug: failed to serve \(fileName): \(error)")
            return Response(status: .notFound)
        }
    }

    private static func stream(_ file: DownloadableFile) -> ResponseBody {
        ResponseBody(contentLength: Int(file.size)) { writer in
            defer { try? file.handle.close() }
            // Exactly the size announced, even if the file grows meanwhile:
            // the connection stays open for the next request, so a byte past
            // it would be read as the start of the next response.
            var remaining = file.size
            while remaining > 0 {
                let count = Int(min(UInt64(chunkSize), remaining))
                // Each chunk comes back autoreleased, and nothing drains the
                // pool while the download runs, so without one per read the
                // whole file would pile up in memory.
                let chunk = try autoreleasepool {
                    try file.handle.read(upToCount: count)
                }
                // The file shrank: ending the connection tells the client at
                // once, instead of leaving it waiting for the missing bytes.
                guard let chunk, !chunk.isEmpty else {
                    throw DownloadError.unavailable
                }
                remaining -= UInt64(chunk.count)
                // Suspends while the console is slow to take the bytes.
                try await writer.write(ByteBuffer(bytes: chunk))
            }
            try await writer.finish(nil)
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
