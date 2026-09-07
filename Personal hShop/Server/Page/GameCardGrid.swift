import Swifter

/// The grid of scannable codes, one card per game.
enum GameCardGrid {

    static func render(_ cards: [GameCard]) {
        div {
            classs = "grid"
            for card in cards {
                renderCard(card)
            }
        }
    }

    private static func renderCard(_ card: GameCard) {
        figure {
            classs = "card"
            div {
                classs = "qr"
                renderCode(card)
            }
            figcaption {
                inner = HTMLText.escaped(card.name)
            }
        }
    }

    private static func renderCode(_ card: GameCard) {
        guard let qr = card.qrDataURI else {
            span {
                classs = "qr-failed"
                inner = "QR code unavailable"
            }
            return
        }
        img {
            src = qr
            alt = HTMLText.escaped(card.name)
        }
    }
}
