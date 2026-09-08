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
        pageText: PageText,
        for request: HttpRequest
    ) -> HttpResponse {
        // Every code is rendered before the page is laid out, so the markup
        // below is only about structure.
        let cards = games.map {
            GameCard(game: $0, baseURL: baseURL, qrCode: qrCode)
        }

        return scopes {
            html {
                lang = pageText.language
                PageHead.render()
                IndexPage.renderBody(
                    cards: cards,
                    baseURL: baseURL,
                    pageText: pageText
                )
            }
        }(request)
    }

    private static func renderBody(
        cards: [GameCard],
        baseURL: String,
        pageText: PageText
    ) {
        body {
            h1 {
                inner = "Personal hShop"
            }
            p {
                classs = "hint"
                inner = hint(
                    cards: cards,
                    baseURL: baseURL,
                    pageText: pageText
                )
            }
            if !cards.isEmpty {
                GameCardGrid.render(cards, pageText: pageText)
            }
        }
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
