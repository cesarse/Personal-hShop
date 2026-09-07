import Foundation
import Testing

@testable import Personal_hShop

struct CIAParserTests {

    private let parser = CIAParser()

    @Test("Reads the title out of the meta section")
    func readsTitleFromMetaSection() throws {
        let file = CIAFixture.cia(
            metaSize: 0x3AC0,
            content: Data(count: 64),
            meta: CIAFixture.meta(around: CIAFixture.smdh(title: "From Meta"))
        )

        let title = try parser.extractEnglishTitle(
            from: InMemoryByteReader(file)
        )

        #expect(title == "From Meta")
    }

    @Test("Falls back to scanning the content when there is no meta section")
    func fallsBackToScanningContent() throws {
        var content = Data(count: 100)
        content.append(CIAFixture.smdh(title: "From Content"))
        let file = CIAFixture.cia(metaSize: 0, content: content)

        let title = try parser.extractEnglishTitle(
            from: InMemoryByteReader(file)
        )

        #expect(title == "From Content")
    }

    @Test("Prefers the meta section over scanning the content")
    func prefersMetaSectionOverScan() throws {
        var content = Data(count: 100)
        content.append(CIAFixture.smdh(title: "From Content"))
        let file = CIAFixture.cia(
            metaSize: 0x3AC0,
            content: content,
            meta: CIAFixture.meta(around: CIAFixture.smdh(title: "From Meta"))
        )

        let title = try parser.extractEnglishTitle(
            from: InMemoryByteReader(file)
        )

        #expect(title == "From Meta")
    }

    @Test("Uses only the locators it was given")
    func usesInjectedLocators() {
        // The block is plainly there, so finding nothing can only mean the
        // parser asked no one to look.
        let file = CIAFixture.cia(
            metaSize: 0x3AC0,
            content: Data(count: 64),
            meta: CIAFixture.meta(around: CIAFixture.smdh(title: "From Meta"))
        )
        let withoutLocators = CIAParser(locators: [])

        #expect(throws: ParserError.smdhNotFound) {
            _ = try withoutLocators.extractEnglishTitle(
                from: InMemoryByteReader(file)
            )
        }
    }

    @Test("Reports a file with no block anywhere")
    func reportsMissingSMDH() {
        let file = CIAFixture.cia(metaSize: 0, content: Data(count: 4096))

        #expect(throws: ParserError.smdhNotFound) {
            _ = try parser.extractEnglishTitle(from: InMemoryByteReader(file))
        }
    }

    @Test("Reports a file too short to hold a header")
    func reportsInvalidHeader() {
        #expect(throws: ParserError.invalidHeader) {
            _ = try parser.extractEnglishTitle(
                from: InMemoryByteReader(Data(count: 16))
            )
        }
    }
}
