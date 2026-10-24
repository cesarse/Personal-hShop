import AppKit
import Foundation
import Hummingbird
import NIOCore
import SwiftUI

/// Runs the HTTP server and wires each route to the type that answers it.
@MainActor
final class Webserver: ObservableObject {

    @AppStorage("port") private var port: Int = 1234
    @AppStorage("openPage") private var openPage: Bool = false

    static let instance = Webserver()
    @Published private(set) var isRunning: Bool = false

    /// A connection with nothing to do is closed after this long, so idle
    /// clients cannot hold on to sockets. It never cuts a download short:
    /// the timer only runs between requests.
    private static let idleTimeout = TimeAmount.seconds(30)

    private let bookmarkStore: BookmarkStore
    private let library: GameLibrary

    /// The task running the current server, if any.
    private var serving: Task<Void, Never>?
    /// The task of a server still shutting down, which must have let go of
    /// the port before another one can bind it.
    private var stopping: Task<Void, Never>?
    /// Bumped by every start and stop, so a server ending late cannot touch
    /// the state of the one that replaced it.
    private var generation = 0

    private init() {
        // One store for both routes, so the folder is resolved the same way
        // whether a page is being rendered or a file served.
        bookmarkStore = BookmarkStore()
        library = GameLibrary(bookmarkStore: bookmarkStore)
        FileDescriptorLimit.raise(to: 4096)
    }

    /// Returns once the server is listening, or throws why it could not.
    func start() async throws {
        if serving != nil { return }
        // The stored value is whatever was typed in Settings, so it may not
        // be a port at all.
        guard let listeningPort = ServerPort(port) else {
            throw ServerPortError.outOfRange
        }
        generation += 1
        let current = generation
        let portNumber = Int(listeningPort.number)
        let listening = ListeningSignal()
        // Qualified: the app's own entry point is also called Application.
        let application = Hummingbird.Application(
            router: makeRouter(port: portNumber),
            server: .http1(configuration: .init(idleTimeout: Self.idleTimeout)),
            configuration: ApplicationConfiguration(
                address: .hostname("0.0.0.0", port: portNumber),
                serverName: nil
            ),
            onServerRunning: { _ in listening.resolve(.success(())) }
        )

        let previous = stopping
        serving = Task {
            await previous?.value
            do {
                try await application.run()
                // Ended without an error before listening: it was stopped.
                listening.resolve(.failure(CancellationError()))
            } catch {
                listening.resolve(.failure(error))
            }
            self.servingEnded(current)
        }

        do {
            try await listening.wait()
        } catch {
            // Stopped while starting: nothing went wrong.
            guard generation == current else { return }
            serving = nil
            throw ServerStartError(error, port: portNumber)
        }
        guard generation == current else { return }
        isRunning = true

        if openPage, let url = URL(string: "http://localhost:\(portNumber)") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Closes the port and every connection, downloads included.
    func stop() {
        guard let serving else { return }
        generation += 1
        serving.cancel()
        stopping = serving
        self.serving = nil
        isRunning = false
        // Nothing is being sent any more, so the Mac may sleep right away.
        KeepAwake.shared.release()
    }

    /// The server can also end on its own, when its socket fails.
    private func servingEnded(_ run: Int) {
        guard run == generation else { return }
        serving = nil
        isRunning = false
        KeepAwake.shared.release()
    }

    private func makeRouter(port: Int) -> Router<BasicRequestContext> {
        let index = IndexResponder(library: library, port: port)
        let downloads = DownloadResponder(bookmarkStore: bookmarkStore)

        // HEAD gets the GET headers without the body, as it did with Swifter,
        // so `curl -I` and download managers still see what is there.
        let router = Router(options: .autoGenerateHeadEndpoints)
        router.get("/") { request, _ in
            await index.respond(to: request)
        }
        router.get(RouterPath(DownloadRoute.pattern)) { _, context in
            downloads.respond(toSegment: context.parameters.get("name"))
        }
        return router
    }
}
