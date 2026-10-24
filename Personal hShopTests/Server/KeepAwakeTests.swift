import Testing

@testable import Personal_hShop

@MainActor
struct KeepAwakeTests {

    @Test("Sending bytes keeps the Mac awake, and stopping lets it sleep")
    func holdsUntilReleased() {
        let keepAwake = KeepAwake(linger: .seconds(60))

        #expect(!keepAwake.isHeld)
        keepAwake.touch()
        #expect(keepAwake.isHeld)
        keepAwake.release()
        #expect(!keepAwake.isHeld)
    }

    @Test("Lets go on its own once nothing has been sent for a while")
    func expiresAfterTheLinger() async throws {
        let keepAwake = KeepAwake(linger: .milliseconds(200))

        keepAwake.touch()
        try await Task.sleep(for: .milliseconds(500))

        #expect(!keepAwake.isHeld)
    }

    @Test("Every chunk sent pushes the end back")
    func postponesWhileBytesKeepGoing() async throws {
        let keepAwake = KeepAwake(linger: .milliseconds(300))

        for _ in 0..<5 {
            keepAwake.touch()
            try await Task.sleep(for: .milliseconds(150))
        }
        #expect(keepAwake.isHeld)

        try await Task.sleep(for: .milliseconds(500))
        #expect(!keepAwake.isHeld)
    }

    @Test("Can be held again after being released")
    func holdsAgainAfterRelease() async throws {
        let keepAwake = KeepAwake(linger: .milliseconds(200))

        keepAwake.touch()
        keepAwake.release()
        keepAwake.touch()
        #expect(keepAwake.isHeld)

        try await Task.sleep(for: .milliseconds(500))
        #expect(!keepAwake.isHeld)
    }
}
