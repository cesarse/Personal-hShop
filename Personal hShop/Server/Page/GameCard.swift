/// One game as the index page shows it: a caption and the code to scan.
struct GameCard {

    let name: String

    /// `nil` when the code could not be rendered.
    let qrDataURI: String?

    init(game: Game, baseURL: String, qrCode: QRCode) {
        name = game.displayName
        qrDataURI = qrCode.dataURI(
            for: DownloadRoute.url(base: baseURL, fileName: game.fileName)
        )
    }
}
