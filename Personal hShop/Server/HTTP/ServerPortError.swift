import Foundation

enum ServerPortError: LocalizedError {
    case outOfRange

    var errorDescription: String? {
        switch self {
        case .outOfRange:
            return String(
                localized: "The server port must be between 1 and 65535."
            )
        }
    }
}
