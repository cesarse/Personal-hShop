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

        // 2. Align offsets to 64 bytes.
        // Widen before adding: a corrupt size field close to UInt32.max
        // overflows a UInt32 add, and Swift traps rather than wrapping.
        let align64 = { (size: UInt32) -> UInt64 in
            return (UInt64(size) + 63) & ~63
        }

        // Calculate absolute offset of the main Content section.
        // Sections are laid out header, cert chain, ticket, TMD, content,
        // each padded to 64 bytes. Meta is not included here: it trails the
        // content rather than preceding it.
        let contentOffset =
            align64(headerAllocSize) + align64(certChainSize)
            + align64(ticketSize) + align64(tmdSize)

        // 3. Scan the content section for the SMDH block
        // Because ExeFS offsets shift, we seek directly to the content block and scan for the "SMDH" magic anchor
        try fileHandle.seek(toOffset: contentOffset)

        // Read chunks of the application data to find the icon data
        let scanBufferSize = 1024 * 1024  // 1MB chunks
        var currentOffset = contentOffset
        var smdhAbsoluteOffset: UInt64? = nil

        let magic = smdhMagic.data(using: .ascii)!
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
}
