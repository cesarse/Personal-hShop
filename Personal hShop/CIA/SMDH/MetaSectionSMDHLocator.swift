import Foundation

/// Looks for the SMDH at its fixed offset inside the CIA meta section.
///
/// The meta section trails the content, lies outside the encrypted region
/// and holds the SMDH at a fixed offset, so this costs one seek and works
/// for titles whose content cannot be read.
struct MetaSectionSMDHLocator: SMDHLocating {

    /// Where the SMDH sits inside a CIA meta section.
    private static let iconOffset: UInt32 = 0x400

    func locateSMDH(in reader: ByteReader, header: CIAHeader) throws -> UInt64?
    {
        guard let candidate = offset(in: header, fileSize: reader.size) else {
            return nil
        }
        let found = try reader.read(at: candidate, count: SMDH.magic.count)
        return found == SMDH.magic ? candidate : nil
    }

    /// Absolute offset of the SMDH inside the meta section, when the CIA has
    /// one large enough to hold it and that offset really lies in the file.
    ///
    /// Every step is bounds checked: a corrupt header can otherwise point far
    /// outside the file, and seeking there fails outright rather than simply
    /// finding nothing.
    private func offset(in header: CIAHeader, fileSize: UInt64) -> UInt64? {
        let smallestUsableMeta =
            MetaSectionSMDHLocator.iconOffset + SMDH.size
        guard header.metaSize >= smallestUsableMeta,
            let meta = header.metaOffset
        else {
            return nil
        }

        let icon = meta.addingReportingOverflow(
            UInt64(MetaSectionSMDHLocator.iconOffset)
        )
        guard !icon.overflow else { return nil }

        let end = icon.partialValue.addingReportingOverflow(UInt64(SMDH.size))
        guard !end.overflow, end.partialValue <= fileSize else { return nil }

        return icon.partialValue
    }
}
