import Testing

@testable import Personal_hShop

struct ServerPortTests {

    @Test("Accepts every port the server can listen on")
    func acceptsValidPorts() {
        #expect(ServerPort(1)?.number == 1)
        #expect(ServerPort(1234)?.number == 1234)
        #expect(ServerPort(65535)?.number == 65535)
    }

    @Test("Rejects what is not a port instead of trapping")
    func rejectsInvalidPorts() {
        // Port 0 asks the system for any free port, which the QR codes could
        // not name.
        #expect(ServerPort(0) == nil)
        #expect(ServerPort(-1) == nil)
        #expect(ServerPort(65536) == nil)
        #expect(ServerPort(123456) == nil)
    }
}
