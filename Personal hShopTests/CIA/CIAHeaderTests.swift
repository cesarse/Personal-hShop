import Foundation
import Testing

@testable import Personal_hShop

struct CIAHeaderTests {

    @Test("Reads the section sizes out of the size table")
    func readsSectionSizes() throws {
        let header = try CIAHeader(
            data: CIAFixture.header(metaSize: 0x3AC0, contentSize: 4096)
        )

        #expect(header.metaSize == 0x3AC0)
        #expect(header.contentSize == 4096)
    }

    @Test("Pads every section ahead of the content to 64 bytes")
    func alignsSectionsTo64Bytes() throws {
        let header = try CIAHeader(
            data: CIAFixture.header(metaSize: 0, contentSize: 0)
        )

        // 0x20, 0x10, 0x10 and 0x10 each round up to 0x40.
        #expect(header.contentOffset == 0x100)
    }

    @Test("Puts the meta section after the padded content")
    func metaFollowsContent() throws {
        let header = try CIAHeader(
            data: CIAFixture.header(metaSize: 0x3AC0, contentSize: 100)
        )

        // 100 bytes of content occupy 128 once padded.
        #expect(header.metaOffset == 0x100 + 128)
    }

    @Test("Refuses a size table that is not exactly 32 bytes")
    func rejectsWrongLength() {
        #expect(throws: ParserError.invalidHeader) {
            _ = try CIAHeader(data: Data(count: 16))
        }
        #expect(throws: ParserError.invalidHeader) {
            _ = try CIAHeader(data: Data(count: 64))
        }
    }

    @Test("Reports no meta section when the header's numbers overflow")
    func metaOffsetIsNilOnOverflow() throws {
        let header = try CIAHeader(
            data: CIAFixture.header(metaSize: 0x3AC0, contentSize: .max)
        )

        #expect(header.metaOffset == nil)
    }
}
