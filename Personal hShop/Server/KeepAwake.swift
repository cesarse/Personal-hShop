import Foundation

/// Keeps the Mac from idle-sleeping while files are being sent.
///
/// A console takes many minutes over its Wi-Fi while nobody touches the
/// Mac, which would otherwise idle-sleep and cut the install short. One
/// activity covers every download, and each chunk sent pushes its end back,
/// so it outlasts the last byte (still in the network buffers, or a pause
/// while the next code is scanned) yet lets go of a console that has stopped
/// reading.
@MainActor
final class KeepAwake {

    /// FBI gives up on a download after 15 seconds without data, so a minute
    /// with nothing sent means nothing more is coming.
    static let shared = KeepAwake(linger: .seconds(60))

    private let linger: Duration
    private var activity: (any NSObjectProtocol)?
    private var deadline = ContinuousClock.now
    private var expiry: Task<Void, Never>?

    init(linger: Duration) {
        self.linger = linger
    }

    var isHeld: Bool { activity != nil }

    /// Called whenever bytes go out.
    func touch() {
        deadline = .now + linger
        if activity == nil {
            activity = ProcessInfo.processInfo.beginActivity(
                options: [.userInitiated, .idleSystemSleepDisabled],
                reason: "Sending a .cia file to a console"
            )
        }
        if expiry == nil {
            expiry = Task { await self.releaseWhenIdle() }
        }
    }

    /// Lets the Mac sleep straight away, as when the server is stopped.
    func release() {
        expiry?.cancel()
        expiry = nil
        end()
    }

    private func releaseWhenIdle() async {
        while ContinuousClock.now < deadline {
            do {
                try await Task.sleep(until: deadline)
            } catch {
                return  // Released in the meantime.
            }
        }
        guard !Task.isCancelled else { return }
        expiry = nil
        end()
    }

    private func end() {
        if let activity {
            ProcessInfo.processInfo.endActivity(activity)
        }
        activity = nil
    }
}
