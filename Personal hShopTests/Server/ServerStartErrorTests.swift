import Foundation
import Testing

@testable import Personal_hShop

struct ServerStartErrorTests {

    @Test("A port taken by another app is named, with what to do about it")
    func explainsABusyPort() {
        let error = ServerStartError(errno: EADDRINUSE, port: 1234)

        // The wording follows the Mac's language; the port is in all of them,
        // written without grouping.
        #expect(error.errorDescription?.contains("1234") == true)
        #expect(error.recoverySuggestion?.isEmpty == false)
    }

    @Test("Any other failure keeps the system's short explanation")
    func keepsTheReasonOfOtherFailures() {
        let error = ServerStartError(errno: EPERM, port: 80)

        #expect(error.errorDescription?.isEmpty == false)
        #expect(error.recoverySuggestion == "Operation not permitted")
    }
}
