import Foundation

/// Scans the content section for the "SMDH" magic anchor.
///
/// ExeFS offsets shift between titles, so there is no fixed place to look:
/// this walks the content section in chunks and searches each one.
struct ContentScanSMDHLocator: SMDHLocating {

    /// Read the application data in 1MB chunks.
    private static let chunkSize = 1024 * 1024

    /// Safety cap to avoid scanning gigabytes of data unnecessarily.
    private static let scanLimit: UInt64 = 50 * 1024 * 1024

    func locateSMDH(in reader: ByteReader, header: CIAHeader) throws -> UInt64?
    {
        let start = header.contentOffset
        var currentOffset = start
        // Tail of the previous chunk, re-examined with the next one so a
        // magic value split across a read boundary is still found.
        var carry = Data()

        while true {
            let chunk = try reader.read(
                at: currentOffset,
                count: ContentScanSMDHLocator.chunkSize
            )
            if chunk.isEmpty { break }

            let window = carry + chunk
            if let range = window.range(of: SMDH.magic) {
                return currentOffset - UInt64(carry.count)
                    + UInt64(range.lowerBound)
            }

            currentOffset += UInt64(chunk.count)
            carry = Data(window.suffix(SMDH.magic.count - 1))
            if currentOffset - start > ContentScanSMDHLocator.scanLimit {
                break
            }
        }

        return nil
    }
}
