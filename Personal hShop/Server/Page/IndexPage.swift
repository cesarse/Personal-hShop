import Foundation

/// The page listing every game as a QR code the 3DS can scan.
struct IndexPage {

    private let qrCode: QRCode

    init(qrCode: QRCode = QRCode()) {
        self.qrCode = qrCode
    }

    /// The whole document. It is built from its arguments alone, so any
    /// number of requests can render it at the same time.
    func html(games: [Game], baseURL: String, pageText: PageText) -> String {
        // Every code is rendered before the page is laid out, so the markup
        // below is only about structure.
        let cards = games.map {
            GameCard(game: $0, baseURL: baseURL, qrCode: qrCode)
        }

        return "<!DOCTYPE html>"
            + "<html lang=\"\(HTMLText.escaped(pageText.language))\">"
            + PageHead.html(pageText: pageText)
            + IndexPage.body(cards: cards, baseURL: baseURL, pageText: pageText)
            + "</html>"
    }

    private static func body(
        cards: [GameCard],
        baseURL: String,
        pageText: PageText
    ) -> String {
        let grid =
            cards.isEmpty ? "" : GameCardGrid.html(cards, pageText: pageText)
        return "<body>"
            + "<h1 translate=\"no\">Personal hShop</h1>"
            + "<p class=\"hint\">"
            + hint(cards: cards, baseURL: baseURL, pageText: pageText)
            + "</p>"
            + grid
            + "</body>"
    }

    private static func hint(
        cards: [GameCard],
        baseURL: String,
        pageText: PageText
    ) -> String {
        guard !cards.isEmpty else {
            return pageText.localized("No .cia files found")
        }
        // "Remote Install" and "Scan QR Code" are FBI's own menu labels and
        // FBI has no localisations, so they stay in English everywhere.
        return pageText.localized(
            """
            In FBI, choose Remote Install → Scan QR Code, then point the 3DS \
            at a code below. Available at \(HTMLText.escaped(baseURL)).
            """
        )
    }
}
