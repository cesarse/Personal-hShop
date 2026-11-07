import HummingbirdCore
import Logging
import NIOCore

/// `HTTP1Channel`, with every accepted connection held in a
/// `SelfClosingConnection` until it is served.
struct SelfClosingHTTP1Channel: ServerChildChannel {

    let http1: HTTP1Channel

    func setup(
        channel: any Channel,
        logger: Logger
    ) -> EventLoopFuture<SelfClosingConnection> {
        http1.setup(channel: channel, logger: logger)
            .map(SelfClosingConnection.init)
    }

    func handle(value: SelfClosingConnection, logger: Logger) async {
        await http1.handle(value: value.http1Connection, logger: logger)
    }
}

extension HTTPServerBuilder {

    /// `http1(configuration:)`, with connections that close themselves.
    static func selfClosingHTTP1(idleTimeout: TimeAmount) -> HTTPServerBuilder {
        HTTPServerBuilder { responder in
            SelfClosingHTTP1Channel(
                http1: HTTP1Channel(
                    responder: responder,
                    configuration: .init(idleTimeout: idleTimeout)
                )
            )
        }
    }
}
