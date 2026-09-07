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
}
