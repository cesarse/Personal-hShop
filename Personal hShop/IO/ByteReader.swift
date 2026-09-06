import Foundation

/// Random access to a stream of bytes.
///
/// Parsing only ever needs to know how large the input is and to read a run
/// of bytes from a given offset, so that is all this asks for. Keeping it
/// that small means an in-memory implementation is enough to exercise every
/// parsing rule, with no real CIA file on disk.
protocol ByteReader {

    /// Total number of bytes available.
    var size: UInt64 { get }

    /// Reads up to `count` bytes starting at `offset`, returning fewer bytes
    /// near the end of the input and none at all past it.
    func read(at offset: UInt64, count: Int) throws -> Data
}
