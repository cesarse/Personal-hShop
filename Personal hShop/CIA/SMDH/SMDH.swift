import Foundation

/// The facts about an SMDH block's binary layout.
enum SMDH {

    /// Anchor marking the start of the block.
    static let magic = Data("SMDH".utf8)

    /// Total length of the block, in bytes.
    static let size: UInt32 = 0x36C0

    /// English is the second title slot (index 1). Each slot is 0x200 bytes
    /// and the block header ahead of them is 0x08, so the English slot
    /// starts at 0x08 + (1 * 0x200).
    static let englishShortDescriptionOffset: UInt64 = 0x0208

    /// 64 UTF-16 characters.
    static let shortDescriptionLength = 128
}
