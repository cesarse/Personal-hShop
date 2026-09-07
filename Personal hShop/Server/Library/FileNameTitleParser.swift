import Foundation

/// Recovers the game name from the usual release naming convention:
/// "<16-hex title id> <name> (<product code>) (v<version>) (<region>)".
///
/// Plan B for the common case. An encrypted CIA with no meta section
/// carries no readable title anywhere in its bytes, and that describes
/// most of a real library, so the file name is all that is left.
struct FileNameTitleParser {

    func title(from fileName: String) -> String? {
        var name = fileName

        // Trailing ".cia" and the scene tag before it ("legit",
        // "piratelegit", "standard") are not part of the name.
        if let dotCIA = name.range(
            of: ".cia",
            options: [.backwards, .caseInsensitive]
        ), dotCIA.upperBound == name.endIndex {
            name = String(name[..<dotCIA.lowerBound])
        }

        // A 16-digit hex title ID leads the name when present.
        if name.prefix(16).count == 16,
            name.prefix(16).allSatisfy(\.isHexDigit)
        {
            name = String(name.dropFirst(16))
        }
        name = name.trimmingCharacters(in: .whitespaces)

        if let cut = firstMetadataGroup(in: name) {
            name = String(name[..<cut])
        }

        name = name.trimmingCharacters(
            in: CharacterSet(charactersIn: " -_.").union(
                .whitespacesAndNewlines
            )
        )
        return name.isEmpty ? nil : name
    }

    /// Where the release detail starts, i.e. the first "(...)" that reads as
    /// metadata rather than as part of the title itself.
    func firstMetadataGroup(in name: String) -> String.Index? {
        var searchFrom = name.startIndex
        while let open = name[searchFrom...].firstIndex(of: "("),
            let close = name[open...].firstIndex(of: ")")
        {
            let group = String(name[name.index(after: open)..<close])
            if isReleaseMetadata(group) { return open }
            searchFrom = name.index(after: close)
        }
        return nil
    }

    func isReleaseMetadata(_ group: String) -> Bool {
        let upper = group.uppercased()
        // Product code, e.g. "CTR-P-BMAP" for 3DS or "KTR-..." for New 3DS.
        if upper.hasPrefix("CTR-") || upper.hasPrefix("KTR-") { return true }
        // Version, e.g. "v0.1.0".
        if upper.hasPrefix("V"), group.count > 1,
            group.dropFirst().allSatisfy({ $0.isNumber || $0 == "." })
        {
            return true
        }
        // Region or language, e.g. "E", "W", "USA", "JPN".
        if !upper.isEmpty, upper.count <= 3, upper.allSatisfy(\.isLetter) {
            return true
        }
        return false
    }
}
