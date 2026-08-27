//
//  CIAParser.swift
//  Personal hShop
//
//  Created by César Seragiotto on 27/08/2026.
//

import Foundation

struct CIAParser {
    // Standard structural constants
    private static let ciaHeaderSize = 0x20
    private static let smdhMagic = "SMDH"
    private static let smdhSize: UInt32 = 0x36C0
    /// Where the SMDH sits inside a CIA meta section.
    private static let metaIconOffset: UInt32 = 0x400

    enum ParserError: Error {
        case invalidHeader
        case cannotRead
        case contentNotFound
        case smdhNotFound
    }

    /// Parses a CIA file and extracts the English game title
    static func extractEnglishTitle(from url: URL) throws -> String {
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer { try? fileHandle.close() }

        // 1. Read CIA Header Size Table (32 bytes)
        guard let headerData = try fileHandle.read(upToCount: ciaHeaderSize),
            headerData.count == ciaHeaderSize
        else {
            throw ParserError.invalidHeader
        }

        // Extract block sizes (UInt32, Little Endian)
        let field = { (offset: Int) -> UInt32 in
            headerData.withUnsafeBytes {
                UInt32(
                    littleEndian: $0.loadUnaligned(
                        fromByteOffset: offset, as: UInt32.self))
            }
        }
        let headerAllocSize = field(0x00)
        let certChainSize = field(0x08)
        let ticketSize = field(0x0C)
        let tmdSize = field(0x10)
        let metaSize = field(0x14)
        let contentSize = headerData.withUnsafeBytes {
            UInt64(
                littleEndian: $0.loadUnaligned(
                    fromByteOffset: 0x18, as: UInt64.self))
        }

        // 2. Align offsets to 64 bytes.
        // Saturate rather than add: a corrupt size field close to the top of
        // the range overflows, and Swift traps instead of wrapping.
        let align64 = { (size: UInt64) -> UInt64 in
            guard size <= UInt64.max - 63 else { return UInt64.max }
            return (size + 63) & ~63
        }

        // Calculate absolute offset of the main Content section.
        // Sections are laid out header, cert chain, ticket, TMD, content,
        // meta; each padded to 64 bytes. Meta is not included here: it
        // trails the content rather than preceding it.
        let contentOffset =
            align64(UInt64(headerAllocSize)) + align64(UInt64(certChainSize))
            + align64(UInt64(ticketSize)) + align64(UInt64(tmdSize))

        let magic = smdhMagic.data(using: .ascii)!
        var smdhAbsoluteOffset: UInt64? = nil

        // 3a. Prefer the meta section. It trails the content, lies outside
        // the encrypted region, and holds the SMDH at a fixed offset, so it
        // costs one seek and works for titles whose content cannot be read.
        let fileSize = try fileHandle.seekToEnd()
        if let candidate = metaSMDHOffset(
            contentOffset: contentOffset,
            contentSize: contentSize,
            metaSize: metaSize,
            fileSize: fileSize,
            align64: align64
        ) {
            try fileHandle.seek(toOffset: candidate)
            if let found = try fileHandle.read(upToCount: magic.count),
                found == magic
            {
                smdhAbsoluteOffset = candidate
            }
        }

        // 3b. Otherwise scan the content section for the SMDH block.
        // Because ExeFS offsets shift, we seek directly to the content block and scan for the "SMDH" magic anchor
        if smdhAbsoluteOffset == nil {
            try fileHandle.seek(toOffset: contentOffset)

            // Read chunks of the application data to find the icon data
            let scanBufferSize = 1024 * 1024  // 1MB chunks
            var currentOffset = contentOffset
            // Tail of the previous chunk, re-examined with the next one so a
            // magic value split across a read boundary is still found.
            var carry = Data()

            while let chunk = try fileHandle.read(upToCount: scanBufferSize),
                !chunk.isEmpty
            {
                let window = carry + chunk
                if let range = window.range(of: magic) {
                    smdhAbsoluteOffset =
                        currentOffset - UInt64(carry.count)
                        + UInt64(range.lowerBound)
                    break
                }
                currentOffset += UInt64(chunk.count)
                carry = Data(window.suffix(magic.count - 1))
                // Safety cap to avoid scanning gigabytes of data unnecessarily
                if currentOffset - contentOffset > 50 * 1024 * 1024 { break }
            }
        }

        guard let smdhOffset = smdhAbsoluteOffset else {
            throw ParserError.smdhNotFound
        }

        // 4. Read the SMDH English Slot
        // English is the second slot (index 1). Each slot is 0x200 bytes.
        // Start offset = SMDH Header (0x0008) + (1 * 0x0200) = 0x0208
        let englishTitleOffset = smdhOffset + 0x0208
        let shortDescriptionLength = 128  // 64 UTF-16 characters

        try fileHandle.seek(toOffset: englishTitleOffset)
        guard
            let titleData = try fileHandle.read(
                upToCount: shortDescriptionLength)
        else {
            throw ParserError.cannotRead
        }

        // 5. Decode UTF-16LE string and remove trailing null characters
        if let rawTitle = String(data: titleData, encoding: .utf16LittleEndian)
        {
            return rawTitle.trimmingCharacters(in: CharacterSet(["\0"]))
        }

        throw ParserError.cannotRead
    }

    /// Absolute offset of the SMDH inside the meta section, when the CIA has
    /// one large enough to hold it and that offset really lies in the file.
    ///
    /// Every step is bounds checked: a corrupt header can otherwise point far
    /// outside the file, and seeking there fails outright rather than simply
    /// finding nothing.
    private static func metaSMDHOffset(
        contentOffset: UInt64,
        contentSize: UInt64,
        metaSize: UInt32,
        fileSize: UInt64,
        align64: (UInt64) -> UInt64
    ) -> UInt64? {
        guard metaSize >= metaIconOffset + smdhSize else { return nil }

        let meta = contentOffset.addingReportingOverflow(align64(contentSize))
        guard !meta.overflow else { return nil }

        let icon = meta.partialValue.addingReportingOverflow(
            UInt64(metaIconOffset)
        )
        guard !icon.overflow else { return nil }

        let end = icon.partialValue.addingReportingOverflow(UInt64(smdhSize))
        guard !end.overflow, end.partialValue <= fileSize else { return nil }

        return icon.partialValue
    }
}
