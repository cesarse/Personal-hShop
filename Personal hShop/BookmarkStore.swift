import Foundation

final class BookmarkStore {
    private let key = "selectedFolderBookmark"

    func saveBookmarkData(_ data: Data) {
        UserDefaults.standard.set(data, forKey: key)
    }

    func withSecurityScopedFolderAccess<T>(
        operation: (URL) throws -> T
    ) throws -> T {
        guard let bookmarkData = UserDefaults.standard.data(forKey: key) else {
            throw FolderAccessError.couldNotStartSecurityScopedAccess
        }

        var isStale = false
        let folderURL = try URL(
            resolvingBookmarkData: bookmarkData,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )

        let didStartAccessing = folderURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                folderURL.stopAccessingSecurityScopedResource()
            }
        }

        guard didStartAccessing else {
            throw FolderAccessError.couldNotStartSecurityScopedAccess
        }

        if isStale {
            let refreshed = try folderURL.bookmarkData(
                options: [
                    .withSecurityScope, .securityScopeAllowOnlyReadAccess,
                ],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            saveBookmarkData(refreshed)
        }

        return try operation(folderURL)
    }
}
