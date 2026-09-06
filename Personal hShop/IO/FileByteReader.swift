import Foundation

/// A `ByteReader` over a file on disk.
///
/// A class rather than a struct because it owns the open descriptor and
/// closes it again in `deinit`, which is a lifetime only a reference type
/// can express.
final class FileByteReader: ByteReader {

    let size: UInt64
    private let handle: FileHandle

    init(url: URL) throws {
        let handle = try FileHandle(forReadingFrom: url)
        do {
            size = try handle.seekToEnd()
        } catch {
            try? handle.close()
            throw error
        }
        self.handle = handle
    }

    deinit {
        try? handle.close()
    }

    func read(at offset: UInt64, count: Int) throws -> Data {
        try handle.seek(toOffset: offset)
        return try handle.read(upToCount: count) ?? Data()
    }
}
