import Synchronization

/// Tells `Webserver.start()` whether the socket ended up listening.
///
/// The server reports success from one task and failure from another, and
/// either may arrive before anyone waits, so the first outcome is kept and
/// every later one is ignored.
final class ListeningSignal: Sendable {

    private enum State {
        case pending
        case waiting(CheckedContinuation<Void, any Error>)
        case resolved(Result<Void, any Error>)
        case finished
    }

    private let state = Mutex<State>(.pending)

    /// Waits for the outcome. Called once.
    func wait() async throws {
        try await withCheckedThrowingContinuation { continuation in
            let early = state.withLock { state -> Result<Void, any Error>? in
                switch state {
                case .pending:
                    state = .waiting(continuation)
                    return nil
                case .resolved(let result):
                    state = .finished
                    return result
                case .waiting, .finished:
                    preconditionFailure("ListeningSignal waited on twice")
                }
            }
            if let early { continuation.resume(with: early) }
        }
    }

    func resolve(_ result: Result<Void, any Error>) {
        let waiting = state.withLock {
            state -> CheckedContinuation<Void, any Error>? in
            switch state {
            case .pending:
                state = .resolved(result)
                return nil
            case .waiting(let continuation):
                state = .finished
                return continuation
            case .resolved, .finished:
                return nil
            }
        }
        waiting?.resume(with: result)
    }
}
