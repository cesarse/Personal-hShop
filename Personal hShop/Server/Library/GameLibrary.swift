import Foundation

/// The `.cia` files in the shared folder, named and in the order the page
/// lists them.
struct GameLibrary {

    private let bookmarkStore: BookmarkStore
    private let titleResolver: GameTitleResolver

    init(
        bookmarkStore: BookmarkStore = BookmarkStore(),
        titleResolver: GameTitleResolver = GameTitleResolver()
    ) {
        self.bookmarkStore = bookmarkStore
        self.titleResolver = titleResolver
    }

    func games() -> [Game] {
        do {
            return try bookmarkStore.withSecurityScopedFolderAccess {
                folderURL in
                let allFiles = try FileManager.default
                    .contentsOfDirectory(atPath: folderURL.path)
                return
                    allFiles
                    .filter { $0.lowercased().hasSuffix(".cia") }
                    .sorted {
                        $0.localizedStandardCompare($1) == .orderedAscending
                    }
                    .map { fileName in
                        Game(
                            fileName: fileName,
                            displayName: titleResolver.displayName(
                                for: fileName,
                                in: folderURL
                            )
                        )
                    }
            }
        } catch {
            print("debug: failed to list files: \(error)")
            return []
        }
    }
}
