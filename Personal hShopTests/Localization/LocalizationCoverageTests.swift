import Foundation
import Testing

@testable import Personal_hShop

/// Guards against a key drifting out of the catalogues, which shows up at
/// runtime only as text quietly appearing in English.
struct LocalizationCoverageTests {

    private static let languages = ["de", "en", "es", "fr", "it", "pt-BR"]
    private static let tables = ["Localizable", "WebPage"]

    private func keys(_ language: String, _ table: String) -> Set<String> {
        guard
            let path = Bundle.main.path(
                forResource: language,
                ofType: "lproj"
            ),
            let bundle = Bundle(path: path),
            let strings = bundle.path(forResource: table, ofType: "strings"),
            let entries = NSDictionary(contentsOfFile: strings)
                as? [String: String]
        else {
            return []
        }
        return Set(entries.keys)
    }

    @Test("Every language carries both catalogues")
    func everyLanguageIsBundled() {
        for language in Self.languages {
            for table in Self.tables {
                #expect(
                    !keys(language, table).isEmpty,
                    "\(language)/\(table) is missing or empty"
                )
            }
        }
    }

    @Test("Every language translates exactly the English keys")
    func noKeyIsMissed() {
        for table in Self.tables {
            let english = keys("en", table)
            for language in Self.languages where language != "en" {
                #expect(
                    keys(language, table) == english,
                    "\(language)/\(table) does not match the English keys"
                )
            }
        }
    }

    @Test("No translation was left as the English source")
    func nothingIsUntranslated() {
        // "Personal hShop" is a product name and is not in the catalogues,
        // so anything left identical here is an oversight.
        for language in Self.languages where language != "en" {
            for table in Self.tables {
                guard
                    let path = Bundle.main.path(
                        forResource: language,
                        ofType: "lproj"
                    ),
                    let bundle = Bundle(path: path),
                    let file = bundle.path(
                        forResource: table,
                        ofType: "strings"
                    ),
                    let entries = NSDictionary(contentsOfFile: file)
                        as? [String: String]
                else {
                    Issue.record("\(language)/\(table) unreadable")
                    continue
                }
                for (key, value) in entries {
                    #expect(key != value, "\(language)/\(table): \(key)")
                }
            }
        }
    }
}
