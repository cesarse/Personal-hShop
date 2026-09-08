import Foundation
import SwiftUI
import Swifter

/// Runs the HTTP server and wires each route to the type that answers it.
final class Webserver: ObservableObject {

    @AppStorage("port") private var port: Int = 1234
    @AppStorage("openPage") private var openPage: Bool = false

    static let instance = Webserver()
    @Published var isRunning: Bool = false

    private let server = HttpServer()
    private let library: GameLibrary
    private let indexPage: IndexPage
    private let address: ServerAddress
    private let downloads: DownloadResponder

    private init() {
        // One store for both routes, so the folder is resolved the same way
        // whether a page is being rendered or a file served.
        let bookmarkStore = BookmarkStore()
        library = GameLibrary(bookmarkStore: bookmarkStore)
        indexPage = IndexPage()
        address = ServerAddress()
        downloads = DownloadResponder(bookmarkStore: bookmarkStore)
    }

    func start() throws {
        if isRunning { return }
        server["/"] = { [weak self] request in
            self?.renderIndexPage(request) ?? .notFound
        }
        server[DownloadRoute.pattern] = { [weak self] request in
            self?.downloads.respond(to: request) ?? .notFound
        }
        try server.start(UInt16(port), forceIPv4: true)
        print("debug: server started")
        isRunning = true
        if openPage, let url = URL(string: "http://localhost:\(port)") {
            NSWorkspace.shared.open(url)
        }
    }

    func stop() {
        if !isRunning { return }
        server.stop()
        print("debug: server stopped")
        isRunning = false
    }

    private func renderIndexPage(_ request: HttpRequest) -> HttpResponse {
        // The 3DS resolves whatever the QR code contains over the network, so
        // the codes have to carry an absolute URL this Mac answers on. A
        // relative path or "localhost" would be useless to the console.
        let baseURL = address.baseURL(for: request, port: port)
        let games = library.games()
        print("debug: ", games.map(\.fileName))

        return indexPage.response(
            games: games,
            baseURL: baseURL,
            pageText: PageText(
                acceptLanguage: request.headers["accept-language"]
            ),
            for: request
        )
    }
}
