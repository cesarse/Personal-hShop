import Foundation

@testable import Personal_hShop

/// A `ByteReader` over bytes already in memory.
///
/// This is what `ByteReader` exists for: every parsing rule can be checked
/// without a real CIA file on disk. It matches `FileByteReader` in the two
/// places that matter to a parser — a short read near the end of the input,
/// and no bytes at all past it.
struct InMemoryByteReader: ByteReader {

    private let bytes: Data

    init(_ bytes: Data) {
        self.bytes = bytes
    }

    var size: UInt64 { UInt64(bytes.count) }

    func read(at offset: UInt64, count: Int) throws -> Data {
        guard offset < size else { return Data() }
        let start = Int(offset)
        // Rebased, because `FileHandle` also hands back a zero-based `Data`.
        return Data(bytes[start..<min(start + count, bytes.count)])
    }
}
