import Foundation
import Testing

@testable import Personal_hShop

struct LocalizedPageTests {

    private func markup(acceptLanguage: String?, games: [Game]) throws -> String
    {
        IndexPage().html(
            games: games,
            baseURL: "http://10.0.0.1:1234",
            pageText: PageText(acceptLanguage: acceptLanguage)
        )
    }

    /// The page's description as a browser reads it, whatever the order of
    /// its attributes.
    private func description(in markup: String) -> String? {
        guard
            let tag = markup.firstMatch(
                of: /<meta[^>]*name="description"[^>]*>/),
            let content = tag.output.firstMatch(of: /content="([^"]*)"/)
        else {
            return nil
        }
        // Entities would otherwise count several characters each.
        return String(content.output.1)
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
    }

    @Test(
        "The description alone is enough for Safari to judge the language",
        arguments: ["de", "en", "es", "fr", "it", "pt-BR"]
    )
    func describesThePageAtLength(tag: String) throws {
        let page = try markup(acceptLanguage: tag, games: [])
        let text = try #require(description(in: page))

        #expect(text.count >= PageHead.minimumDescriptionLength)
    }

    @Test("Describes the page in the language it was served in")
    func describesThePageInItsLanguage() throws {
        let french = try markup(acceptLanguage: "fr", games: [])

        #expect(
            description(in: french)?.hasPrefix(
                "Installez sur votre Nintendo 3DS") == true)
    }

    @Test("Declares the language it was served in")
    func declaresTheLanguage() throws {
        #expect(
            try markup(acceptLanguage: "fr", games: []).contains("lang=\"fr\""))
        #expect(
            try markup(acceptLanguage: "pt", games: []).contains(
                "lang=\"pt-BR\"")
        )
    }

    @Test("An empty library says so in the requested language")
    func translatesTheEmptyState() throws {
        let french = try markup(acceptLanguage: "fr", games: [])
        let german = try markup(acceptLanguage: "de;q=0.9", games: [])

        #expect(french.contains("Aucun fichier .cia trouvé"))
        #expect(german.contains("Keine .cia-Dateien gefunden"))
    }

    @Test("A populated library translates the instruction")
    func translatesTheInstruction() throws {
        let games = [Game(fileName: "g.cia", displayName: "G")]
        let spanish = try markup(acceptLanguage: "es-ES,es;q=0.9", games: games)

        #expect(spanish.contains("Disponible en http://10.0.0.1:1234."))
        // FBI's own menu labels stay in English.
        #expect(spanish.contains("Remote Install → Scan QR Code"))
    }

    @Test("The product name is never translated")
    func keepsTheProductName() throws {
        for tag in ["de", "es", "fr", "it", "pt-BR"] {
            #expect(
                try markup(acceptLanguage: tag, games: []).contains(
                    "Personal hShop"))
        }
    }

    /// Safari skips text inside a form when judging the page's language,
    /// which keeps the English titles from outvoting the page's own words.
    @Test("The titles are kept out of Safari's language sample")
    func keepsTitlesOutOfTheLanguageSample() throws {
        let games = [Game(fileName: "g.cia", displayName: "Sonic Lost World")]
        let french = try markup(acceptLanguage: "fr", games: games)

        #expect(french.contains("<form><div class=\"grid\">"))
        #expect(french.contains("</div></form>"))
    }

    @Test("Names are kept out of translation")
    func marksNamesAsUntranslatable() throws {
        let games = [Game(fileName: "g.cia", displayName: "Sonic Lost World")]
        let french = try markup(acceptLanguage: "fr", games: games)

        #expect(french.contains("<h1 translate=\"no\">Personal hShop</h1>"))
        #expect(
            french.contains(
                "<figcaption translate=\"no\">Sonic Lost World</figcaption>"))
    }

    @Test("Each title appears once; the code is described in the page's words")
    func describesTheCodeWithoutRepeatingTheTitle() throws {
        let games = [Game(fileName: "g.cia", displayName: "Sonic Lost World")]
        let french = try markup(acceptLanguage: "fr", games: games)

        #expect(french.components(separatedBy: "Sonic Lost World").count == 2)
        #expect(french.contains("alt=\"Code QR\""))
    }

    /// Several clients may load the page at once, and each must get its own
    /// page, whole and in its own language.
    @Test("Pages rendered at the same time stay apart")
    func rendersConcurrently() async throws {
        let languages = ["de", "en", "es", "fr", "it", "pt-BR"]
        let games = [Game(fileName: "g.cia", displayName: "Sonic Lost World")]
        let expected = try Dictionary(
            uniqueKeysWithValues: languages.map {
                ($0, try markup(acceptLanguage: $0, games: games))
            }
        )

        let rendered = try await withThrowingTaskGroup(
            of: (String, String).self
        ) { group in
            for round in 0..<200 {
                let language = languages[round % languages.count]
                group.addTask {
                    (language, try markup(acceptLanguage: language, games: games))
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }

        #expect(rendered.count == 200)
        for (language, page) in rendered {
            #expect(page == expected[language])
        }
    }
}
