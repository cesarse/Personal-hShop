import Foundation

/// The size table at the start of every CIA, and the section offsets that
/// follow from it.
struct CIAHeader {

    /// Length of the size table itself, in bytes.
    static let size = 0x20

    let contentSize: UInt64
    let metaSize: UInt32

    /// Sections are laid out header, cert chain, ticket, TMD, content, meta,
    /// each padded to 64 bytes. Only the first four precede the content.
    let contentOffset: UInt64

    /// Reads the size table and derives the offsets its sections sit at.
    init(data: Data) throws {
        guard data.count == CIAHeader.size else {
            throw ParserError.invalidHeader
        }

        let littleEndianUInt32 = { (offset: Int) -> UInt32 in
            data.withUnsafeBytes {
                UInt32(
                    littleEndian: $0.loadUnaligned(
                        fromByteOffset: offset, as: UInt32.self))
            }
        }
        let headerAllocSize = littleEndianUInt32(0x00)
        let certChainSize = littleEndianUInt32(0x08)
        let ticketSize = littleEndianUInt32(0x0C)
        let tmdSize = littleEndianUInt32(0x10)
        metaSize = littleEndianUInt32(0x14)
        contentSize = data.withUnsafeBytes {
            UInt64(
                littleEndian: $0.loadUnaligned(
                    fromByteOffset: 0x18, as: UInt64.self))
        }

        contentOffset =
            CIAHeader.align64(UInt64(headerAllocSize))
            + CIAHeader.align64(UInt64(certChainSize))
            + CIAHeader.align64(UInt64(ticketSize))
            + CIAHeader.align64(UInt64(tmdSize))
    }

    /// Absolute offset of the meta section, or `nil` when the header's own
    /// numbers overflow before reaching it.
    var metaOffset: UInt64? {
        let meta = contentOffset.addingReportingOverflow(
            CIAHeader.align64(contentSize)
        )
        return meta.overflow ? nil : meta.partialValue
    }

    /// Rounds a size up to the 64-byte boundary CIA sections are padded to.
    ///
    /// Saturates rather than adds: a corrupt size field close to the top of
    /// the range overflows, and Swift traps instead of wrapping.
    private static func align64(_ size: UInt64) -> UInt64 {
        guard size <= UInt64.max - 63 else { return UInt64.max }
        return (size + 63) & ~63
    }
}
