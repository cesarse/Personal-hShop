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

    /// Sends exactly the size announced, even if the file grows meanwhile:
    /// the connection stays open for the next request, so a byte past it would
    /// be read as the start of the next response. Writing suspends while the
    /// console is slow to take the bytes.
    private static func stream(_ file: DownloadableFile) -> ResponseBody {
        ResponseBody(contentLength: Int(file.size)) { writer in
            defer { try? file.handle.close() }
            await KeepAwake.shared.touch()
            var remaining = file.size
            while remaining > 0 {
                let chunk = try readNextChunk(
                    of: file,
                    upToCount: Int(min(UInt64(chunkSize), remaining))
                )
                remaining -= UInt64(chunk.count)
                try await writer.write(ByteBuffer(bytes: chunk))
                await KeepAwake.shared.touch()
            }
            try await writer.finish(nil)
        }
    }

    /// Each chunk comes back autoreleased, and nothing drains the pool while
    /// the download runs, so without a pool per read the whole file would pile
    /// up in memory.
    ///
    /// Throws when the file has shrunk: ending the connection tells the client
    /// at once, instead of leaving it waiting for the missing bytes.
    private static func readNextChunk(
        of file: DownloadableFile,
        upToCount count: Int
    ) throws -> Data {
        let chunk = try autoreleasepool {
            try file.handle.read(upToCount: count)
        }
        guard let chunk, !chunk.isEmpty else {
            throw DownloadError.unavailable
        }
        return chunk
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
