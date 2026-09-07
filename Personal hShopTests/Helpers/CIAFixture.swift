import Foundation

@testable import Personal_hShop

/// Builds CIA-shaped bytes: the size table, the padding the format requires,
/// then the content and meta sections exactly where the header says they are.
enum CIAFixture {

    /// The offset the content section lands at for every fixture built here,
    /// given the section sizes `header(metaSize:contentSize:)` writes.
    static let contentOffset: UInt64 = 0x100

    /// A 32-byte size table on its own.
    static func header(metaSize: UInt32, contentSize: UInt64) -> Data {
        var header = Data(count: CIAHeader.size)
        header.replaceSubrange(0x00..<0x04, with: littleEndian(UInt32(0x20)))
        header.replaceSubrange(0x08..<0x0C, with: littleEndian(UInt32(0x10)))
        header.replaceSubrange(0x0C..<0x10, with: littleEndian(UInt32(0x10)))
        header.replaceSubrange(0x10..<0x14, with: littleEndian(UInt32(0x10)))
        header.replaceSubrange(0x14..<0x18, with: littleEndian(metaSize))
        header.replaceSubrange(0x18..<0x20, with: littleEndian(contentSize))
        return header
    }

    /// A whole file: header, padding, content, then meta.
    static func cia(
        metaSize: UInt32,
        content: Data,
        meta: Data = Data()
    ) -> Data {
        var file = header(
            metaSize: metaSize,
            contentSize: UInt64(content.count)
        )
        file.append(Data(count: Int(contentOffset) - file.count))
        file.append(content)
        // The content section is padded to 64 bytes, so the meta section
        // behind it starts where the header says it does.
        file.append(Data(count: aligned(content.count) - content.count))
        file.append(meta)
        return file
    }

    private static func aligned(_ size: Int) -> Int {
        (size + 63) & ~63
    }

    /// A meta section holding `smdh` at the fixed offset the locator expects.
    static func meta(around smdh: Data) -> Data {
        var meta = Data(count: 0x400)
        meta.append(smdh)
        return meta
    }

    /// An SMDH block carrying `title` in the English short-description slot.
    static func smdh(title: String) -> Data {
        var encoded = Data()
        for unit in title.utf16 {
            encoded.append(UInt8(unit & 0xFF))
            encoded.append(UInt8(unit >> 8))
        }
        return smdh(titleBytes: encoded)
    }

    /// An SMDH block whose English slot holds `titleBytes` verbatim, padded
    /// out to the slot's fixed width.
    static func smdh(titleBytes: Data) -> Data {
        var slot = Data(titleBytes.prefix(SMDH.shortDescriptionLength))
        slot.append(Data(count: SMDH.shortDescriptionLength - slot.count))

        var block = Data(count: Int(SMDH.size))
        block.replaceSubrange(0..<SMDH.magic.count, with: SMDH.magic)
        let start = Int(SMDH.englishShortDescriptionOffset)
        block.replaceSubrange(
            start..<(start + SMDH.shortDescriptionLength),
            with: slot
        )
        return block
    }

    private static func littleEndian<T: FixedWidthInteger>(_ value: T) -> Data {
        withUnsafeBytes(of: value.littleEndian) { Data($0) }
    }
}
