import Foundation
import Testing

@testable import Personal_hShop

struct MetaSectionSMDHLocatorTests {

    private let locator = MetaSectionSMDHLocator()

    private func locate(in file: Data) throws -> UInt64? {
        let reader = InMemoryByteReader(file)
        let header = try CIAHeader(
            data: reader.read(at: 0, count: CIAHeader.size)
        )
        return try locator.locateSMDH(in: reader, header: header)
    }

    @Test("Finds the block at its fixed offset inside the meta section")
    func findsSMDHInMetaSection() throws {
        let file = CIAFixture.cia(
            metaSize: 0x3AC0,
            content: Data(count: 64),
            meta: CIAFixture.meta(around: CIAFixture.smdh(title: "Found"))
        )

        // Content starts at 0x100 and occupies 64 bytes; the block sits
        // 0x400 into the meta section that follows.
        #expect(try locate(in: file) == 0x100 + 64 + 0x400)
    }

    @Test("Ignores a meta section too small to hold the block")
    func ignoresUndersizedMeta() throws {
        let file = CIAFixture.cia(
            metaSize: 0x3ABF,
            content: Data(count: 64),
            meta: CIAFixture.meta(around: CIAFixture.smdh(title: "Found"))
        )

        #expect(try locate(in: file) == nil)
    }

    @Test("Ignores a meta section without the magic anchor")
    func ignoresMetaWithoutMagic() throws {
        let file = CIAFixture.cia(
            metaSize: 0x3AC0,
            content: Data(count: 64),
            meta: Data(count: 0x400 + Int(SMDH.size))
        )

        #expect(try locate(in: file) == nil)
    }

    @Test("Ignores a meta section the file stops short of")
    func ignoresTruncatedFile() throws {
        var file = CIAFixture.cia(
            metaSize: 0x3AC0,
            content: Data(count: 64),
            meta: CIAFixture.meta(around: CIAFixture.smdh(title: "Found"))
        )
        file = Data(file.prefix(file.count - 0x2000))

        #expect(try locate(in: file) == nil)
    }
}
