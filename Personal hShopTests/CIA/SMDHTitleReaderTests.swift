import Foundation
import Testing

@testable import Personal_hShop

struct SMDHTitleReaderTests {

    private let reader = SMDHTitleReader()

    @Test("Decodes the English slot and drops its null padding")
    func decodesEnglishTitle() throws {
        let bytes = InMemoryByteReader(CIAFixture.smdh(title: "Some Game"))

        let title = try reader.englishTitle(in: bytes, smdhOffset: 0)

        #expect(title == "Some Game")
    }

    @Test("Keeps a title that fills the whole slot")
    func keepsAFullWidthTitle() throws {
        let full = String(repeating: "A", count: 64)
        let bytes = InMemoryByteReader(CIAFixture.smdh(title: full))

        #expect(try reader.englishTitle(in: bytes, smdhOffset: 0) == full)
    }

    @Test("Reports an empty slot as an empty title")
    func emptySlotDecodesToEmptyString() throws {
        let bytes = InMemoryByteReader(CIAFixture.smdh(title: ""))

        #expect(try reader.englishTitle(in: bytes, smdhOffset: 0) == "")
    }

    @Test("Fails when the block stops before the English slot")
    func failsWhenSlotIsMissing() {
        let truncated = CIAFixture.smdh(title: "Cut Short").prefix(0x100)
        let bytes = InMemoryByteReader(Data(truncated))

        #expect(throws: ParserError.cannotRead) {
            _ = try reader.englishTitle(in: bytes, smdhOffset: 0)
        }
    }

    @Test("Fails when the slot is not valid UTF-16")
    func failsOnUndecodableBytes() {
        // A lone high surrogate cannot begin a UTF-16 scalar. An odd byte
        // count is not enough on its own: Foundation simply drops the stray
        // byte and decodes the rest.
        let bytes = InMemoryByteReader(
            CIAFixture.smdh(titleBytes: Data([0x00, 0xD8]))
        )

        #expect(throws: ParserError.cannotRead) {
            _ = try reader.englishTitle(in: bytes, smdhOffset: 0)
        }
    }
}
