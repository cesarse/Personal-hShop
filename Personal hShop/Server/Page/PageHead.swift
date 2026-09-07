import Swifter

/// Everything in the document's `<head>`.
enum PageHead {

    static func render() {
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
    }
}
