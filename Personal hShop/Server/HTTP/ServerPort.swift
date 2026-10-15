/// A TCP port the server can listen on and the console can call back on.
struct ServerPort {

    /// Port 0 asks the system for any free port, which the QR codes could
    /// not name, so the range starts at 1.
    static let range = 1...Int(UInt16.max)

    let number: UInt16

    /// Fails for anything outside `range`, where `UInt16(_:)` would trap.
    init?(_ candidate: Int) {
        guard Self.range.contains(candidate) else { return nil }
        number = UInt16(candidate)
    }
}
