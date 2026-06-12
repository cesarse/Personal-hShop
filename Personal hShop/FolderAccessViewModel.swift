internal import Combine
import Foundation
import SwiftUI

@MainActor
final class FolderAccessViewModel: ObservableObject {
    @Published private(set) var folderPath: String?
    static let instance = FolderAccessViewModel()
    private let bookmarkStore = BookmarkStore()

    private init() {
        loadSavedFolder()
    }

    func handleFolderImport(_ result: Result<[URL], Error>) {
        do {
            guard let selectedFolderURL = try result.get().first else { return }
            try saveSecurityScopedBookmark(for: selectedFolderURL)
            loadSavedFolder()
        } catch {
            print("debug: handleFolderImport failed: \(error)")
        }
    }

    private func loadSavedFolder() {
        folderPath = try? bookmarkStore.withSecurityScopedFolderAccess { $0.path }
    }

    private func saveSecurityScopedBookmark(for folderURL: URL) throws {
        let didStartAccessing = folderURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                folderURL.stopAccessingSecurityScopedResource()
            }
        }

        let bookmarkData = try folderURL.bookmarkData(
            options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )

        bookmarkStore.saveBookmarkData(bookmarkData)
    }
}

enum FolderAccessError: LocalizedError {
    case couldNotStartSecurityScopedAccess

    var errorDescription: String? {
        switch self {
        case .couldNotStartSecurityScopedAccess:
            return "The app could not start security-scoped access to the selected folder."
        }
    }
}
