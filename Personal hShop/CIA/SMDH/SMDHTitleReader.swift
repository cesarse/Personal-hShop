import Foundation

/// Reads the English short description out of an SMDH block.
struct SMDHTitleReader {

    func englishTitle(in reader: ByteReader, smdhOffset: UInt64) throws
        -> String
    {
        let titleData = try reader.read(
            at: smdhOffset + SMDH.englishShortDescriptionOffset,
            count: SMDH.shortDescriptionLength
        )
        guard !titleData.isEmpty,
            let rawTitle = String(
                data: titleData,
                encoding: .utf16LittleEndian
            )
        else {
            throw ParserError.cannotRead
        }

        let fixedWidthNullPadding = CharacterSet(["\0"])
        return rawTitle.trimmingCharacters(in: fixedWidthNullPadding)
    }
}
