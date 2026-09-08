import Swifter

/// The grid of scannable codes, one card per game.
enum GameCardGrid {

    static func render(_ cards: [GameCard], pageText: PageText) {
        div {
            classs = "grid"
            for card in cards {
                renderCard(card, pageText: pageText)
            }
        }
    }

    private static func renderCard(
        _ card: GameCard,
        pageText: PageText
    ) {
        figure {
            classs = "card"
            div {
                classs = "qr"
                renderCode(card, pageText: pageText)
            }
            figcaption {
                inner = HTMLText.escaped(card.name)
            }
        }
    }

    private static func renderCode(
        _ card: GameCard,
        pageText: PageText
    ) {
        guard let qr = card.qrDataURI else {
            span {
                classs = "qr-failed"
                inner = pageText.localized("QR code unavailable")
            }
            return
        }
        img {
            src = qr
            alt = HTMLText.escaped(card.name)
        }
    }
}
