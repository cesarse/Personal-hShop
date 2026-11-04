import Foundation

/// Recovers the game name from the usual release naming convention:
/// "<16-hex title id> <name> (<product code>) (v<version>) (<region>)".
///
/// Plan B for the common case. An encrypted CIA with no meta section
/// carries no readable title anywhere in its bytes, and that describes
/// most of a real library, so the file name is all that is left.
struct FileNameTitleParser {

    func title(from fileName: String) -> String? {
        var name = removingLeadingTitleID(
            from: removingCIAExtension(from: fileName)
        ).trimmingCharacters(in: .whitespaces)

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

    private func removingCIAExtension(from fileName: String) -> String {
        guard
            let dotCIA = fileName.range(
                of: ".cia",
                options: [.backwards, .caseInsensitive]
            ), dotCIA.upperBound == fileName.endIndex
        else {
            return fileName
        }
        return String(fileName[..<dotCIA.lowerBound])
    }

    private func removingLeadingTitleID(from name: String) -> String {
        let titleIDLength = 16
        let prefix = name.prefix(titleIDLength)
        guard prefix.count == titleIDLength, prefix.allSatisfy(\.isHexDigit)
        else {
            return name
        }
        return String(name.dropFirst(titleIDLength))
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
        isProductCode(group) || isVersion(group) || isRegionOrLanguage(group)
    }

    /// For example "CTR-P-BMAP" for 3DS or "KTR-..." for New 3DS.
    private func isProductCode(_ group: String) -> Bool {
        let upper = group.uppercased()
        return upper.hasPrefix("CTR-") || upper.hasPrefix("KTR-")
    }

    /// For example "v0.1.0".
    private func isVersion(_ group: String) -> Bool {
        group.uppercased().hasPrefix("V") && group.count > 1
            && group.dropFirst().allSatisfy { $0.isNumber || $0 == "." }
    }

    /// For example "E", "W", "USA" or "JPN".
    private func isRegionOrLanguage(_ group: String) -> Bool {
        let upper = group.uppercased()
        return !upper.isEmpty && upper.count <= 3
            && upper.allSatisfy(\.isLetter)
    }
}
