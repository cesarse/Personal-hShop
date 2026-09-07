/// The index page's styling.
enum PageStylesheet {

    static let css = """
        body {
                font: 15px -apple-system, BlinkMacSystemFont, sans-serif;
                margin: 0 auto;
                padding: 2rem 1.5rem 3rem;
                max-width: 1100px;
                color: #1c1c1e;
                background: #f5f5f7;
            }
            h1 { font-size: 1.5rem; margin: 0 0 .25rem; }
            .hint { margin: 0 0 2rem; color: #6b6b70; }
            .grid {
                display: grid;
                gap: 1.25rem;
                grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            }
            .card {
                margin: 0;
                padding: 1rem;
                border-radius: 12px;
                background: #fff;
                box-shadow: 0 1px 3px rgba(0, 0, 0, .12);
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: .75rem;
            }
            /* White padding around the code is the QR quiet zone; without it
               scanners struggle to find the symbol. */
            .qr {
                background: #fff;
                padding: 12px;
                line-height: 0;
            }
            .qr img {
                display: block;
                width: 208px;
                height: 208px;
                image-rendering: pixelated;
            }
            .qr-failed { color: #b00020; font-size: .85rem; }
            figcaption {
                font-size: .8rem;
                line-height: 1.35;
                text-align: center;
                word-break: break-word;
                color: #3a3a3c;
            }
        """
}
