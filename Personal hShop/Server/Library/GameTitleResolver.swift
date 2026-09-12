import Foundation

/// Works out what to call a game.
///
/// The title inside the CIA is authoritative; the file name is the fallback,
/// and the raw name the last resort. An encrypted CIA with no meta section
/// carries no readable title at all, so falling back to the file name is an
/// ordinary outcome here rather than a failure worth surfacing on the page.
struct GameTitleResolver {

    private let ciaParser: CIAParser
    private let fileNameParser: FileNameTitleParser
    private let cache: TitleCache

    init(
        ciaParser: CIAParser = CIAParser(),
        fileNameParser: FileNameTitleParser = FileNameTitleParser(),
        cache: TitleCache = TitleCache()
    ) {
        self.ciaParser = ciaParser
        self.fileNameParser = fileNameParser
        self.cache = cache
    }

    func displayName(for fileName: String, in folderURL: URL) -> String {
        let fileURL = folderURL.appendingPathComponent(fileName)
        let key = TitleCache.key(for: fileURL, fileName: fileName)
        if let cached = cache.title(for: key) { return cached }

        var title = fileNameParser.title(from: fileName) ?? fileName
        do {
            let parsed = try ciaParser.extractEnglishTitle(from: fileURL)
            let cleaned = GameTitleResolver.sanitized(parsed)
            if !cleaned.isEmpty { title = cleaned }
        } catch {
            print("debug: no title in \(fileName): \(error)")
        }

        let displayName = GameTitleCasing.titleCased(title)
        cache.store(displayName, for: key)
        return displayName
    }

    /// SMDH short descriptions are NUL-padded to a fixed width and are free
    /// to wrap onto a second line, neither of which belongs in a caption.
    static func sanitized(_ title: String) -> String {
        String(title.prefix { $0 != "\0" })
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
