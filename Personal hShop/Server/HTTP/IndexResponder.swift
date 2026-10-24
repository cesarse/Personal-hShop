import Foundation
import Hummingbird

/// Answers a request for the index page.
struct IndexResponder {

    private let library: GameLibrary
    private let page: IndexPage
    private let address: ServerAddress
    private let port: Int

    init(
        library: GameLibrary,
        port: Int,
        page: IndexPage = IndexPage(),
        address: ServerAddress = ServerAddress()
    ) {
        self.library = library
        self.port = port
        self.page = page
        self.address = address
    }

    /// Listing the folder can parse CIA files and read large parts of them,
    /// which blocks. That runs on a queue of its own rather than on the few
    /// threads Swift shares with every download in progress.
    func respond(to request: Request) async -> Response {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: render(request))
            }
        }
    }

    private func render(_ request: Request) -> Response {
        // The 3DS resolves whatever the QR code contains over the network, so
        // the codes have to carry an absolute URL this Mac answers on. A
        // relative path or "localhost" would be useless to the console.
        // HTTP/1.1's Host header arrives as the request's authority.
        let baseURL = address.baseURL(host: request.head.authority, port: port)
        let html = page.html(
            games: library.games(),
            baseURL: baseURL,
            pageText: PageText(
                acceptLanguage: request.headers[.acceptLanguage]
            )
        )
        return Response(
            status: .ok,
            headers: [.contentType: "text/html; charset=utf-8"],
            body: ResponseBody(byteBuffer: ByteBuffer(string: html))
        )
    }
}
