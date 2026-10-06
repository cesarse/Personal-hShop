import Swifter

/// The grid of scannable codes, one card per game.
enum GameCardGrid {

    static func render(_ cards: [GameCard], pageText: PageText) {
        // Safari ignores `lang` when deciding whether to offer a
        // translation. It samples the text under fixed points of the
        // window, which land on this grid, and the titles are English, so a
        // French page would read as English and be offered in French.
        // Safari's sampler skips anything inside a <form>, hence this one;
        // there is nothing to submit.
        form {
            div {
                classs = "grid"
                for card in cards {
                    renderCard(card, pageText: pageText)
                }
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
            // Titles are names: a browser translating the page would only
            // garble them.
            element("figcaption", ["translate": "no"]) {
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
        // The caption already names the game; repeating it here would put
        // every title on the page twice.
        img {
            src = qr
            alt = HTMLText.escaped(pageText.localized("QR code"))
        }
    }
}
