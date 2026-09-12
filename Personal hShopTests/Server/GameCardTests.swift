import Testing

@testable import Personal_hShop

struct GameCardTests {

    /// The console fetches exactly the name the QR code carries, so the file
    /// name must reach the URL untouched — case included.
    @Test("Links to the file name exactly as it is on disk")
    func linksToTheUntouchedFileName() {
        let fileName = "0004000000123400 SONIC LOST WORLD.cia"
        let baseURL = "http://10.0.0.1:1234"
        let game = Game(fileName: fileName, displayName: "Sonic Lost World")

        let card = GameCard(game: game, baseURL: baseURL, qrCode: QRCode())

        // Codes are deterministic, so this pins the encoded URL.
        let expected = QRCode().dataURI(
            for: DownloadRoute.url(base: baseURL, fileName: fileName)
        )
        #expect(card.qrDataURI == expected)
    }

    @Test("Captions the card with the display name")
    func captionsWithTheDisplayName() {
        let game = Game(
            fileName: "0004000000123400 SONIC LOST WORLD.cia",
            displayName: "Sonic Lost World"
        )

        let card = GameCard(game: game, baseURL: "http://x", qrCode: QRCode())

        #expect(card.name == "Sonic Lost World")
    }
}
