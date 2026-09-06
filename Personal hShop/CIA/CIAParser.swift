//
//  CIAParser.swift
//  Personal hShop
//
//  Created by César Seragiotto on 27/08/2026.
//

import Foundation

/// Reads the metadata a CIA file carries about itself.
///
/// The parser only sequences the work: read the header, offer it to each
/// locator until one finds the SMDH, then read the title out of the block
/// that was found. Every step that knows a binary layout lives in its own
/// type.
struct CIAParser {

    /// Tried in order, and the first locator to find the SMDH wins. The meta
    /// section comes first because it costs a single seek and works even for
    /// titles whose content cannot be read.
    private let locators: [SMDHLocating]
    private let titleReader: SMDHTitleReader

    init(
        locators: [SMDHLocating] = [
            MetaSectionSMDHLocator(),
            ContentScanSMDHLocator(),
        ],
        titleReader: SMDHTitleReader = SMDHTitleReader()
    ) {
        self.locators = locators
        self.titleReader = titleReader
    }

    /// Parses a CIA file and extracts the English game title
    func extractEnglishTitle(from url: URL) throws -> String {
        try extractEnglishTitle(from: FileByteReader(url: url))
    }

    /// Parses any CIA-shaped run of bytes and extracts the English game title
    func extractEnglishTitle(from reader: ByteReader) throws -> String {
        let header = try CIAHeader(
            data: reader.read(at: 0, count: CIAHeader.size)
        )

        for locator in locators {
            guard
                let smdhOffset = try locator.locateSMDH(
                    in: reader,
                    header: header
                )
            else {
                continue
            }
            return try titleReader.englishTitle(
                in: reader,
                smdhOffset: smdhOffset
            )
        }

        throw ParserError.smdhNotFound
    }
}
