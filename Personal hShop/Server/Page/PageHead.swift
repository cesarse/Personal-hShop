import Swifter

/// Everything in the document's `<head>`.
enum PageHead {

    /// Should Safari's own sampling of the page fail (see `GameCardGrid`),
    /// it judges the page's language from the description instead. A
    /// description at least this long is the whole sample; a shorter one is
    /// padded with text from the page, which here means English game titles.
    static let minimumDescriptionLength = 128

    static func render(pageText: PageText) {
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
            meta {
                name = "description"
                content = HTMLText.escaped(
                    pageText.localized(
                        """
                        Install the games shared from this Mac on your \
                        Nintendo 3DS: open FBI on the console, then scan the \
                        QR code of the game you want to install.
                        """
                    )
                )
            }
            style {
                inner = PageStylesheet.css
            }
        }
    }
}
