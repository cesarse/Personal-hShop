import Foundation
import Swifter
import Testing

@testable import Personal_hShop

/// Collects whatever a response writes, so the markup can be inspected.
private final class BodyCollector: HttpResponseBodyWriter {
    var bytes: [UInt8] = []
    func write(_ file: String.File) throws {}
    func write(_ data: [UInt8]) throws { bytes += data }
    func write(_ data: ArraySlice<UInt8>) throws { bytes += data }
    func write(_ data: NSData) throws {
        bytes += [UInt8](Data(referencing: data))
    }
    func write(_ data: Data) throws { bytes += [UInt8](data) }
}

/// Serialised: Swifter's HTML DSL renders through global mutable state
/// (`scopesBuffer` plus one global per attribute), so two renders running at
/// once corrupt each other.
@Suite(.serialized)
struct LocalizedPageTests {

    private func markup(acceptLanguage: String?, games: [Game]) throws -> String
    {
        let response = IndexPage().response(
            games: games,
            baseURL: "http://10.0.0.1:1234",
            pageText: PageText(acceptLanguage: acceptLanguage),
            for: HttpRequest()
        )
        guard case .raw(_, _, _, let writer) = response, let writer else {
            return ""
        }
        let collector = BodyCollector()
        try writer(collector)
        return String(decoding: collector.bytes, as: UTF8.self)
    }

    /// The page's description as a browser reads it, in whatever order
    /// Swifter wrote the attributes.
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
}
