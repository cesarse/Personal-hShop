import Foundation

/// The page's wording, in the language the browser asked for.
///
/// The Mac's own language says nothing about the browser opening the page —
/// it may well be a phone held up to the console — so the served page is
/// negotiated per request rather than taken from the app.
struct PageText {

    /// Tag for the document's `lang` attribute.
    let language: String

    private let bundle: Bundle

    init(acceptLanguage header: String?) {
        let available = Bundle.main.localizations.filter { $0 != "Base" }
        let asked = AcceptLanguage(header: header).preferences
        language =
            asked.lazy
            .compactMap { PageText.closest(to: $0, among: available) }
            .first
            ?? Bundle.main.preferredLocalizations.first
            ?? "en"
        bundle = PageText.bundle(for: language)
    }

    func localized(_ key: String.LocalizationValue) -> String {
        String(localized: key, table: "WebPage", bundle: bundle)
    }

    /// An exact tag wins. Failing that, the first localisation sharing its
    /// language, so a browser asking for "pt" is still served "pt-BR".
    private static func closest(
        to tag: String,
        among available: [String]
    ) -> String? {
        if let exact = available.first(where: { $0.lowercased() == tag }) {
            return exact
        }
        let asked = PageText.languageSubtag(tag)
        return available.first { PageText.languageSubtag($0) == asked }
    }

    private static func languageSubtag(_ tag: String) -> String {
        String(tag.lowercased().split(separator: "-").first ?? "")
    }

    private static func bundle(for language: String) -> Bundle {
        guard
            let path = Bundle.main.path(forResource: language, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }
        return bundle
    }
}
