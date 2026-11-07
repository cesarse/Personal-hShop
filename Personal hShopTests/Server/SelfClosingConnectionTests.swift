import HummingbirdCore
import Logging
import NIOCore
import NIOEmbedded
import Testing

@testable import Personal_hShop

/// SwiftNIO traps when a connection is released without having been closed, so
/// if this regresses the test host crashes rather than one of these failing.
///
/// These use NIO's in-memory channel because the sandbox stops a signed test
/// host from opening a connection to a real server.
@Suite("SelfClosingConnection", .timeLimit(.minutes(1)))
struct SelfClosingConnectionTests {

    private let channel = NIOAsyncTestingChannel()

    private func accept() async throws -> SelfClosingConnection {
        let http1 = HTTP1Channel(responder: { _, _, _ in })
        let channel = channel
        let accepted = try await channel.testingEventLoop.executeInContext {
            SelfClosingHTTP1Channel(http1: http1).setup(
                channel: channel,
                logger: Logger(label: "test")
            )
        }
        return try await accepted.get()
    }

    private func becomeActive() async throws {
        let address = try SocketAddress(ipAddress: "127.0.0.1", port: 1234)
        try await channel.connect(to: address)
    }

    /// The order that crashed: the server drops the connection, then SwiftNIO
    /// lets go of its own reference as the connection becomes active.
    @Test("Dropped before becoming active, it closes itself")
    func droppedBeforeBecomingActive() async throws {
        _ = try await accept()
        try? await becomeActive()
        try await channel.closeFuture.get()
        #expect(!channel.isActive)
    }

    @Test("Dropped after becoming active, it closes itself")
    func droppedAfterBecomingActive() async throws {
        var connection: SelfClosingConnection? = try await accept()
        try await becomeActive()
        #expect(connection?.channel.isActive == true)
        connection = nil
        try await channel.closeFuture.get()
        #expect(!channel.isActive)
    }

    @Test("Stays open while it is being held")
    func staysOpenWhileHeld() async throws {
        let connection = try await accept()
        try await becomeActive()
        #expect(connection.channel.isActive)
        _ = try await channel.finish(acceptAlreadyClosed: true)
    }
}
