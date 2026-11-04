/// The grid of scannable codes, one card per game.
enum GameCardGrid {

    static func html(_ cards: [GameCard], pageText: PageText) -> String {
        hiddenFromSafariTranslationSampler(
            "<div class=\"grid\">"
                + cards.map { card($0, pageText: pageText) }.joined()
                + "</div>"
        )
    }

    /// Safari ignores `lang` when deciding whether to offer a translation. It
    /// samples the text under fixed points of the window, which land on this
    /// grid, and the titles are English, so a French page would read as English
    /// and be offered in French. The sampler skips anything inside a `<form>`,
    /// hence this one; there is nothing to submit.
    private static func hiddenFromSafariTranslationSampler(
        _ html: String
    ) -> String {
        "<form>\(html)</form>"
    }

    /// The caption is marked `translate="no"`: titles are names, and a browser
    /// translating the page would only garble them.
    private static func card(_ card: GameCard, pageText: PageText) -> String {
        "<figure class=\"card\">"
            + "<div class=\"qr\">\(code(card, pageText: pageText))</div>"
            + "<figcaption translate=\"no\">"
            + HTMLText.escaped(card.name)
            + "</figcaption>"
            + "</figure>"
    }

    /// The alt text does not name the game: the caption already does, and
    /// repeating it would put every title on the page twice.
    private static func code(_ card: GameCard, pageText: PageText) -> String {
        guard let qr = card.qrDataURI else {
            return "<span class=\"qr-failed\">"
                + pageText.localized("QR code unavailable")
                + "</span>"
        }
        let alt = HTMLText.escaped(pageText.localized("QR code"))
        return "<img src=\"\(qr)\" alt=\"\(alt)\">"
    }
}
