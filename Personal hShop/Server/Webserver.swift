import AppKit
import Foundation
import Hummingbird
import NIOCore
import SwiftUI

/// Runs the HTTP server and wires each route to the type that answers it.
@MainActor
final class Webserver: ObservableObject {

    /// Whatever was typed in Settings, so it may not be a port at all.
    @AppStorage("port") private var port: Int = 1234
    @AppStorage("openPage") private var openPage: Bool = false

    static let instance = Webserver()
    @Published private(set) var isRunning: Bool = false

    /// A connection with nothing to do is closed after this long, so idle
    /// clients cannot hold on to sockets. It never cuts a download short:
    /// the timer only runs between requests.
    private static let idleTimeout = TimeAmount.seconds(30)

    /// Shared by both routes, so the folder is resolved the same way whether
    /// a page is being rendered or a file served.
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
        bookmarkStore = BookmarkStore()
        library = GameLibrary(bookmarkStore: bookmarkStore)
        FileDescriptorLimit.raise(to: 4096)
    }

    /// Returns once the server is listening, or throws why it could not.
    /// Being stopped while starting is not an error, so that returns normally.
    func start() async throws {
        if serving != nil { return }
        let portNumber = try validatedPortNumber()
        generation += 1
        let run = generation
        let listening = ListeningSignal()
        serving = launch(
            makeApplication(port: portNumber, listening: listening),
            run: run,
            listening: listening
        )

        do {
            try await listening.wait()
        } catch {
            guard run == generation else { return }
            serving = nil
            throw ServerStartError(error, port: portNumber)
        }
        guard run == generation else { return }
        isRunning = true
        openPageIfEnabled(port: portNumber)
    }

    private func validatedPortNumber() throws -> Int {
        guard let validPort = ServerPort(port) else {
            throw ServerPortError.outOfRange
        }
        return Int(validPort.number)
    }

    private func makeApplication(
        port: Int,
        listening: ListeningSignal
    ) -> some ApplicationProtocol {
        Hummingbird.Application(
            router: makeRouter(port: port),
            server: .selfClosingHTTP1(idleTimeout: Self.idleTimeout),
            configuration: ApplicationConfiguration(
                address: .hostname("0.0.0.0", port: port),
                serverName: nil
            ),
            onServerRunning: { _ in listening.resolve(.success(())) }
        )
    }

    /// Runs `application` once any previous server has let go of the port, and
    /// reports through `listening` if it ends before it started listening.
    private func launch(
        _ application: some ApplicationProtocol,
        run: Int,
        listening: ListeningSignal
    ) -> Task<Void, Never> {
        let previous = stopping
        return Task {
            await previous?.value
            do {
                try await application.run()
                let stoppedBeforeListening = CancellationError()
                listening.resolve(.failure(stoppedBeforeListening))
            } catch {
                listening.resolve(.failure(error))
            }
            self.servingEnded(run)
        }
    }

    private func openPageIfEnabled(port: Int) {
        if openPage, let url = URL(string: "http://localhost:\(port)") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Closes the port and every connection, downloads included. Nothing is
    /// being sent any more, so the Mac may sleep right away.
    func stop() {
        guard let serving else { return }
        generation += 1
        serving.cancel()
        stopping = serving
        self.serving = nil
        isRunning = false
        KeepAwake.shared.release()
    }

    /// The server can also end on its own, when its socket fails.
    private func servingEnded(_ run: Int) {
        guard run == generation else { return }
        serving = nil
        isRunning = false
        KeepAwake.shared.release()
    }

    /// HEAD gets the GET headers without the body, so `curl -I` and download
    /// managers still see what is there.
    private func makeRouter(port: Int) -> Router<BasicRequestContext> {
        let index = IndexResponder(library: library, port: port)
        let downloads = DownloadResponder(bookmarkStore: bookmarkStore)

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
