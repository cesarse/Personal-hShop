import Foundation

enum FolderAccessError: LocalizedError {
    case couldNotStartSecurityScopedAccess

    var errorDescription: String? {
        switch self {
        case .couldNotStartSecurityScopedAccess:
            return
                "The app could not start security-scoped access to the selected folder."
        }
    }
}
