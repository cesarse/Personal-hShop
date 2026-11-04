import Foundation

/// The address the 3DS should call back on.
struct ServerAddress {

    /// A request that already arrived over the network proves which address
    /// reaches this Mac, so its `Host` wins — but only when it is a numeric
    /// address. FBI resolves neither "localhost" nor an mDNS ".local" name,
    /// so anything else falls back to a LAN address found here.
    func baseURL(host: String?, port: Int) -> String {
        if let host,
            ServerAddress.isRoutableIPv4(ServerAddress.hostname(from: host))
        {
            return "http://" + host
        }
        if let address = ServerAddress.lanAddress() {
            return "http://\(address):\(port)"
        }
        return "http://localhost:\(port)"
    }

    /// Strips the port from a `Host` header value, leaving bracketed IPv6
    /// literals and bare (colon-bearing) IPv6 addresses intact.
    static func hostname(from host: String) -> String {
        if host.hasPrefix("[") {
            return String(host.dropFirst().prefix { $0 != "]" })
        }
        let parts = host.split(separator: ":", omittingEmptySubsequences: false)
        return parts.count == 2 ? String(parts[0]) : host
    }

    /// Whether `name` is a numeric IPv4 address outside 127.0.0.0/8. A loopback
    /// address means the page was opened on this Mac, which says nothing about
    /// the address the console should use.
    static func isRoutableIPv4(_ name: String) -> Bool {
        var address = in_addr()
        guard name.withCString({ inet_pton(AF_INET, $0, &address) }) == 1 else {
            return false
        }
        let isLoopback = UInt32(bigEndian: address.s_addr) >> 24 == 127
        return !isLoopback
    }

    private typealias InterfaceAddress = (interface: String, address: String)

    private static func lanAddress() -> String? {
        preferredAddress(among: usableIPv4Addresses())
    }

    /// Prefers en0, then any other en interface: en0 is Wi-Fi or the built-in
    /// Ethernet on every Mac, so it is the interface the 3DS is most likely to
    /// share a network with.
    private static func preferredAddress(
        among candidates: [InterfaceAddress]
    ) -> String? {
        candidates.first { $0.interface == "en0" }?.address
            ?? candidates.first { $0.interface.hasPrefix("en") }?.address
            ?? candidates.first?.address
    }

    private static func usableIPv4Addresses() -> [InterfaceAddress] {
        var head: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&head) == 0, let first = head else { return [] }
        defer { freeifaddrs(head) }

        return sequence(first: first) { $0.pointee.ifa_next }
            .compactMap { usableIPv4Address(of: $0.pointee) }
    }

    /// The address of an interface entry, when the interface is up, is not
    /// loopback and the entry holds an IPv4 address.
    private static func usableIPv4Address(
        of entry: ifaddrs
    ) -> InterfaceAddress? {
        let flags = Int32(entry.ifa_flags)
        guard flags & IFF_UP != 0, flags & IFF_LOOPBACK == 0,
            let address = entry.ifa_addr,
            address.pointee.sa_family == UInt8(AF_INET),
            let host = numericHost(of: address)
        else {
            return nil
        }
        return (String(cString: entry.ifa_name), host)
    }

    private static func numericHost(
        of address: UnsafeMutablePointer<sockaddr>
    ) -> String? {
        var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        let status = getnameinfo(
            address,
            socklen_t(address.pointee.sa_len),
            &host,
            socklen_t(host.count),
            nil,
            0,
            NI_NUMERICHOST
        )
        return status == 0 ? String(cString: host) : nil
    }
}
