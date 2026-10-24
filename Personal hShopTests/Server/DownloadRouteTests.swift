import Testing

@testable import Personal_hShop

struct DownloadRouteTests {

    @Test("Registers one route for every download")
    func exposesTheRoutePattern() {
        #expect(DownloadRoute.pattern == "/files/:name")
    }

    @Test("Escapes a name so it stays a single path component")
    func encodesNames() {
        #expect(DownloadRoute.encoded("a b.cia") == "a%20b.cia")
        // Without this the name would span two path segments.
        #expect(DownloadRoute.encoded("a/b.cia") == "a%2Fb.cia")
        #expect(DownloadRoute.encoded("game.cia") == "game.cia")
    }

    @Test("Builds the absolute URL a QR code carries")
    func buildsDownloadURLs() {
        #expect(
            DownloadRoute.url(
                base: "http://192.168.1.5:1234",
                fileName: "Super Game.cia"
            ) == "http://192.168.1.5:1234/files/Super%20Game.cia"
        )
    }

    @Test("Reads back every name it encodes")
    func decodesWhatItEncodes() {
        for name in ["Super Game.cia", "Pokémon Café.cia", "a#b?c%d.cia"] {
            #expect(
                DownloadRoute.fileName(
                    fromSegment: DownloadRoute.encoded(name)
                ) == name
            )
        }
    }

    @Test("Decodes before the name is checked, so escapes cannot hide a path")
    func decodesEscapedSlashesBeforeTheCheck() throws {
        let name = try #require(
            DownloadRoute.fileName(fromSegment: "..%2Fsecret.cia")
        )

        #expect(name == "../secret.cia")
        #expect(!DownloadResponder.isServableFileName(name))
    }

    @Test("Refuses a segment that is not valid percent-encoding")
    func refusesMalformedEscapes() {
        #expect(DownloadRoute.fileName(fromSegment: "game%ZZ.cia") == nil)
    }
}
