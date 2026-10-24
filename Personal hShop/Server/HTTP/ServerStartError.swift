import Foundation
import NIOCore

/// Why the server did not start, in words the alert can show.
enum ServerStartError: LocalizedError {
    case portInUse(Int)
    case other(detail: String)

    init(_ error: any Error, port: Int) {
        guard let ioError = error as? IOError else {
            self = .other(detail: error.localizedDescription)
            return
        }
        self.init(errno: ioError.errnoCode, port: port)
    }

    init(errno code: Int32, port: Int) {
        // The system's short description, such as "Operation not permitted";
        // NIO's own wording names internal functions.
        self =
            code == EADDRINUSE
            ? .portInUse(port) : .other(detail: String(cString: strerror(code)))
    }

    var errorDescription: String? {
        switch self {
        case .portInUse(let port):
            // Passed as text: a number would be grouped as "1 234" or "1,234"
            // depending on the Mac's language.
            return String(localized: "Port \(String(port)) is already in use.")
        case .other:
            return String(localized: "The server could not start.")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .portInUse:
            return String(
                localized:
                    "Choose another port in Settings, then start the server again."
            )
        case .other(let detail):
            return detail
        }
    }
}
