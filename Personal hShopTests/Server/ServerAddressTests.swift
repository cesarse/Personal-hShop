import Testing

@testable import Personal_hShop

struct ServerAddressTests {

    @Test("Strips the port from a Host header")
    func stripsThePort() {
        #expect(
            ServerAddress.hostname(from: "192.168.1.5:1234")
                == "192.168.1.5"
        )
        #expect(ServerAddress.hostname(from: "localhost:1234") == "localhost")
        #expect(ServerAddress.hostname(from: "192.168.1.5") == "192.168.1.5")
    }

    @Test("Leaves IPv6 literals intact")
    func keepsIPv6Literals() {
        #expect(ServerAddress.hostname(from: "[::1]:80") == "::1")
        // Bare IPv6 carries colons of its own, so none of them is a port.
        #expect(ServerAddress.hostname(from: "::1") == "::1")
    }

    @Test("Accepts an address the console could route to")
    func acceptsRoutableAddresses() {
        #expect(ServerAddress.isRoutableIPv4("192.168.1.5"))
        #expect(ServerAddress.isRoutableIPv4("10.0.0.1"))
    }

    @Test("Rejects loopback and anything that is not a numeric IPv4")
    func rejectsUnusableAddresses() {
        // Loopback says the page was opened on this Mac, which tells us
        // nothing about the address the console should use.
        #expect(!ServerAddress.isRoutableIPv4("127.0.0.1"))
        #expect(!ServerAddress.isRoutableIPv4("127.5.5.5"))
        // FBI resolves neither of these.
        #expect(!ServerAddress.isRoutableIPv4("localhost"))
        #expect(!ServerAddress.isRoutableIPv4("mac.local"))
        #expect(!ServerAddress.isRoutableIPv4("::1"))
    }
}
