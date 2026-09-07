import Foundation
import Swifter

/// The page listing every game as a QR code the 3DS can scan.
struct IndexPage {

    private let qrCode: QRCode

    init(qrCode: QRCode = QRCode()) {
        self.qrCode = qrCode
    }

    func response(
        games: [Game],
        baseURL: String,
        for request: HttpRequest
    ) -> HttpResponse {
        // Every code is rendered before the page is laid out, so the markup
        // below is only about structure.
        let cards = games.map {
            GameCard(game: $0, baseURL: baseURL, qrCode: qrCode)
        }

        return scopes {
            html {
                PageHead.render()
                IndexPage.renderBody(cards: cards, baseURL: baseURL)
            }
        }(request)
    }

    private static func renderBody(cards: [GameCard], baseURL: String) {
        body {
            h1 {
                inner = "Personal hShop"
            }
            p {
                classs = "hint"
                inner = hint(cards: cards, baseURL: baseURL)
            }
            if !cards.isEmpty {
                GameCardGrid.render(cards)
            }
        }
    }

    private static func hint(cards: [GameCard], baseURL: String) -> String {
        guard !cards.isEmpty else { return "No .cia files found" }
        return
            "In FBI, choose Remote Install &rarr; Scan QR "
            + "Code, then point the 3DS at a code below. "
            + "Serving from " + HTMLText.escaped(baseURL) + "."
    }
}
