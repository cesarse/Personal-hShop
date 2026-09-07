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
        let cards = games.map { game in
            (
                name: game.displayName,
                qr: qrCode.dataURI(
                    for: DownloadRoute.url(
                        base: baseURL,
                        fileName: game.fileName
                    )
                )
            )
        }

        return scopes {
            html {
                head {
                    meta {
                        charset = "utf-8"
                    }
                    meta {
                        name = "viewport"
                        content = "width=device-width, initial-scale=1"
                    }
                    title {
                        inner = "Personal hShop"
                    }
                    style {
                        inner = PageStylesheet.css
                    }
                }
                body {
                    h1 {
                        inner = "Personal hShop"
                    }
                    if cards.isEmpty {
                        p {
                            classs = "hint"
                            inner = "No .cia files found"
                        }
                    } else {
                        p {
                            classs = "hint"
                            inner =
                                "In FBI, choose Remote Install &rarr; Scan QR "
                                + "Code, then point the 3DS at a code below. "
                                + "Serving from "
                                + IndexPage.htmlEscaped(baseURL) + "."
                        }
                        div {
                            classs = "grid"
                            for card in cards {
                                figure {
                                    classs = "card"
                                    div {
                                        classs = "qr"
                                        if let qr = card.qr {
                                            img {
                                                src = qr
                                                alt = IndexPage.htmlEscaped(
                                                    card.name
                                                )
                                            }
                                        } else {
                                            span {
                                                classs = "qr-failed"
                                                inner =
                                                    "QR code unavailable"
                                            }
                                        }
                                    }
                                    figcaption {
                                        inner = IndexPage.htmlEscaped(
                                            card.name
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }(request)
    }

    static func htmlEscaped(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}
