/// The grid of scannable codes, one card per game.
enum GameCardGrid {

    static func html(_ cards: [GameCard], pageText: PageText) -> String {
        // Safari ignores `lang` when deciding whether to offer a
        // translation. It samples the text under fixed points of the
        // window, which land on this grid, and the titles are English, so a
        // French page would read as English and be offered in French.
        // Safari's sampler skips anything inside a <form>, hence this one;
        // there is nothing to submit.
        "<form><div class=\"grid\">"
            + cards.map { card($0, pageText: pageText) }.joined()
            + "</div></form>"
    }

    private static func card(_ card: GameCard, pageText: PageText) -> String {
        // Titles are names: a browser translating the page would only
        // garble them.
        "<figure class=\"card\">"
            + "<div class=\"qr\">\(code(card, pageText: pageText))</div>"
            + "<figcaption translate=\"no\">"
            + HTMLText.escaped(card.name)
            + "</figcaption>"
            + "</figure>"
    }

    private static func code(_ card: GameCard, pageText: PageText) -> String {
        guard let qr = card.qrDataURI else {
            return "<span class=\"qr-failed\">"
                + pageText.localized("QR code unavailable")
                + "</span>"
        }
        // The caption already names the game; repeating it here would put
        // every title on the page twice.
        let alt = HTMLText.escaped(pageText.localized("QR code"))
        return "<img src=\"\(qr)\" alt=\"\(alt)\">"
    }
}
