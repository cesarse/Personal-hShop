import HummingbirdCore
import NIOCore

/// An accepted connection that closes itself if nobody ever serves it.
///
/// Stopping the server can drop a connection it has only just accepted, and
/// SwiftNIO traps when a connection is released without having been closed.
final class SelfClosingConnection: ServerChildChannelValue, Sendable {

    let http1Connection: HTTP1Channel.Value

    var channel: any Channel { http1Connection.channel }

    init(_ http1Connection: HTTP1Channel.Value) {
        self.http1Connection = http1Connection
    }

    /// Closing a connection that was already served does nothing.
    deinit {
        Task { [http1Connection] in
            try? await http1Connection.executeThenClose { _, _ in }
        }
    }
}
