import Foundation

/// A page of the app's documentation on GitHub, opened in the language the
/// app is showing when it has been translated, and in English otherwise.
enum OnlineDocument: String {

    /// Getting started and troubleshooting, the guide the Start window is too
    /// short to hold.
    case support = "SUPPORT"

    /// Apple requires a link to the privacy policy inside the app.
    case privacyPolicy = "PRIVACY"

    /// Named like the app's localizations. A language missing here falls
    /// back to the English page instead of a page that does not exist.
    private static let translations: Set<String> = [
        "de", "es", "fr", "it", "pt-BR",
    ]

    private static let folder = URL(
        string: "https://github.com/cesarse/Personal-hShop/blob/main/"
    )!

    /// The page in the language the app is showing, which macOS picks from
    /// the app's localizations as it does for the rest of the interface.
    var url: URL {
        url(in: Bundle.main.preferredLocalizations.first ?? "en")
    }

    /// English pages keep the plain name and translations add the language,
    /// as in `SUPPORT-pt-BR.md`.
    func url(in language: String) -> URL {
        let fileName =
            Self.translations.contains(language)
            ? "\(rawValue)-\(language).md"
            : "\(rawValue).md"
        return Self.folder.appending(path: fileName)
    }
}
