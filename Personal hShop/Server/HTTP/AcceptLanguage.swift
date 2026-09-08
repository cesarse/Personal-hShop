import Foundation

/// The languages a browser asked for, best first.
struct AcceptLanguage {

    /// Language tags in descending order of preference, lowercased.
    let preferences: [String]

    /// Reads an `Accept-Language` header: a comma-separated list of tags,
    /// each with an optional `q` weight that orders them.
    init(header: String?) {
        guard let header else {
            preferences = []
            return
        }
        preferences =
            header
            .split(separator: ",")
            .compactMap(AcceptLanguage.entry)
            .enumerated()
            // Equal weights keep the order they were written in, which the
            // header's own order already expresses.
            .sorted {
                $0.element.quality == $1.element.quality
                    ? $0.offset < $1.offset
                    : $0.element.quality > $1.element.quality
            }
            .map(\.element.tag)
    }

    /// One `tag;q=weight` item. A missing weight means the tag is fully
    /// wanted; "*" is dropped, since asking for anything is what the
    /// fallback already does.
    private static func entry(
        _ item: Substring
    ) -> (tag: String, quality: Double)? {
        let parts = item.split(separator: ";")
        let tag =
            parts.first?
            .trimmingCharacters(in: .whitespaces)
            .lowercased() ?? ""
        guard !tag.isEmpty, tag != "*" else { return nil }

        let weight =
            parts
            .dropFirst()
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { $0.hasPrefix("q=") }
            .flatMap { Double($0.dropFirst(2)) }
        return (tag, weight ?? 1)
    }
}
