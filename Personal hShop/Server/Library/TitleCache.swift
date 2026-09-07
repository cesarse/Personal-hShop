import Foundation

/// Titles already read out of the CIA files.
///
/// Parsing scans a large part of each file, and the index page is rendered
/// afresh on every request, so the result has to be kept. A class because
/// every caller has to see the same entries.
final class TitleCache {

    private var titles: [String: String] = [:]
    private let lock = NSLock()

    /// A key for `fileURL` that stops matching as soon as the file changes,
    /// built from its name, size and modification date.
    static func key(for fileURL: URL, fileName: String) -> String {
        let attributes = try? FileManager.default.attributesOfItem(
            atPath: fileURL.path
        )
        let size = (attributes?[.size] as? NSNumber)?.int64Value ?? 0
        let modified =
            (attributes?[.modificationDate] as? Date)?
            .timeIntervalSince1970 ?? 0
        return "\(fileName)|\(size)|\(modified)"
    }

    func title(for key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return titles[key]
    }

    func store(_ title: String, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        titles[key] = title
    }
}
