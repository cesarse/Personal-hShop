import Testing

@testable import Personal_hShop

struct DownloadResponderTests {

    @Test("Serves a plain .cia name")
    func acceptsPlainNames() {
        #expect(DownloadResponder.isServableFileName("game.cia"))
        #expect(DownloadResponder.isServableFileName("Game.CIA"))
        #expect(DownloadResponder.isServableFileName("Pokémon Café.cia"))
    }

    @Test("Refuses anything that could escape the shared folder")
    func refusesPathTraversal() {
        #expect(!DownloadResponder.isServableFileName("../game.cia"))
        #expect(!DownloadResponder.isServableFileName("sub/game.cia"))
        #expect(!DownloadResponder.isServableFileName("sub\\game.cia"))
        #expect(!DownloadResponder.isServableFileName(".."))
        #expect(!DownloadResponder.isServableFileName("."))
    }

    @Test("Refuses control characters, which could forge headers")
    func refusesControlCharacters() {
        #expect(!DownloadResponder.isServableFileName("game\r\n.cia"))
        #expect(!DownloadResponder.isServableFileName("game\t.cia"))
    }

    @Test("Refuses names that are empty, over-long or not a .cia")
    func refusesOtherNames() {
        #expect(!DownloadResponder.isServableFileName(""))
        #expect(!DownloadResponder.isServableFileName("game.txt"))
        #expect(
            !DownloadResponder.isServableFileName(
                String(repeating: "z", count: 300) + ".cia"
            )
        )
    }

    @Test("Offers the name in both a quoted and an encoded form")
    func buildsContentDisposition() {
        #expect(
            DownloadHeaders.contentDisposition(for: "game.cia")
                == "attachment; filename=\"game.cia\"; "
                + "filename*=UTF-8''game.cia"
        )
    }

    @Test("Keeps quotes and backslashes out of the quoted form")
    func escapesTheQuotedForm() {
        let header = DownloadHeaders.contentDisposition(
            for: "a\"b\\c.cia"
        )

        #expect(header.contains("filename=\"abc.cia\""))
    }

    @Test("Escapes everything RFC 8187 does not allow in the encoded form")
    func escapesTheEncodedForm() {
        let header = DownloadHeaders.contentDisposition(for: "a;b=c (é).cia")

        #expect(header.hasSuffix("filename*=UTF-8''a%3Bb%3Dc%20%28%C3%A9%29.cia"))
    }
}
