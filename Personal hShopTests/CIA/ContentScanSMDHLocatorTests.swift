import Foundation
import Testing

@testable import Personal_hShop

struct ContentScanSMDHLocatorTests {

    /// The chunk the locator reads at a time. Kept here rather than read from
    /// the locator so a change to it has to be a deliberate one.
    private static let chunkSize = 1024 * 1024

    private let locator = ContentScanSMDHLocator()

    private func locate(in file: Data) throws -> UInt64? {
        let reader = InMemoryByteReader(file)
        let header = try CIAHeader(
            data: reader.read(at: 0, count: CIAHeader.size)
        )
        return try locator.locateSMDH(in: reader, header: header)
    }

    /// A CIA with no usable meta section and `smdh` buried `padding` bytes
    /// into the content, so only the scan can find it.
    private func fileWithSMDH(after padding: Int) -> Data {
        var content = Data(count: padding)
        content.append(CIAFixture.smdh(title: "Scanned"))
        return CIAFixture.cia(metaSize: 0, content: content)
    }

    @Test("Finds the magic anchor inside the content section")
    func findsMagicInContent() throws {
        #expect(try locate(in: fileWithSMDH(after: 100)) == 0x100 + 100)
    }

    @Test("Finds a magic anchor split across two chunks")
    func findsMagicAcrossChunkBoundary() throws {
        // Leaves "SM" at the end of the first chunk and "DH" in the second,
        // which only the carry between reads can bridge.
        let padding = Self.chunkSize - 2
        let found = try locate(in: fileWithSMDH(after: padding))

        #expect(found == 0x100 + UInt64(padding))
    }

    @Test("Gives up rather than scanning past the safety cap")
    func stopsAtScanCap() throws {
        #expect(try locate(in: fileWithSMDH(after: 51 * 1024 * 1024)) == nil)
    }

    @Test("Keeps reading past the content section to the end of the file")
    func scansBeyondTheContentSection() throws {
        // Nothing in the content, and the anchor only in the meta section
        // behind it. The scan is bounded by the file and the safety cap
        // rather than by the section it starts in, so it still gets there.
        let file = CIAFixture.cia(
            metaSize: 0,
            content: Data(count: 64),
            meta: CIAFixture.meta(around: CIAFixture.smdh(title: "Behind"))
        )

        #expect(try locate(in: file) == 0x100 + 64 + 0x400)
    }

    @Test("Finds nothing in content that has no magic anchor")
    func findsNothingWithoutMagic() throws {
        let file = CIAFixture.cia(metaSize: 0, content: Data(count: 4096))

        #expect(try locate(in: file) == nil)
    }
}
