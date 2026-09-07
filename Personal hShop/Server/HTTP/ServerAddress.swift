import Foundation
import Swifter

/// The address the 3DS should call back on.
struct ServerAddress {

    /// A request that already arrived over the network proves which address
    /// reaches this Mac, so its `Host` wins — but only when it is a numeric
    /// address. FBI resolves neither "localhost" nor an mDNS ".local" name,
    /// so anything else falls back to a LAN address found here.
    func baseURL(for request: HttpRequest, port: Int) -> String {
        if let host = request.headers["host"],
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

    static func isRoutableIPv4(_ name: String) -> Bool {
        var address = in_addr()
        guard name.withCString({ inet_pton(AF_INET, $0, &address) }) == 1 else {
            return false
        }
        // 127.0.0.0/8 means the page was opened on this Mac, which tells us
        // nothing about the address the console should use.
        return UInt32(bigEndian: address.s_addr) >> 24 != 127
    }

    /// First usable IPv4 address of an up, non-loopback interface.
    private static func lanAddress() -> String? {
        var head: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&head) == 0, let first = head else { return nil }
        defer { freeifaddrs(head) }

        var candidates: [(interface: String, address: String)] = []
        for pointer in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let flags = Int32(pointer.pointee.ifa_flags)
            guard flags & IFF_UP != 0, flags & IFF_LOOPBACK == 0,
                let address = pointer.pointee.ifa_addr,
                address.pointee.sa_family == UInt8(AF_INET)
            else {
                continue
            }

            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            guard
                getnameinfo(
                    address,
                    socklen_t(address.pointee.sa_len),
                    &host,
                    socklen_t(host.count),
                    nil,
                    0,
                    NI_NUMERICHOST
                ) == 0
            else {
                continue
            }

            candidates.append(
                (
                    String(cString: pointer.pointee.ifa_name),
                    String(cString: host)
                )
            )
        }

        // en0 is Wi-Fi or the built-in Ethernet on every Mac, so it is the
        // interface the 3DS is most likely to share a network with.
        return candidates.first { $0.interface == "en0" }?.address
            ?? candidates.first { $0.interface.hasPrefix("en") }?.address
            ?? candidates.first?.address
    }
}
