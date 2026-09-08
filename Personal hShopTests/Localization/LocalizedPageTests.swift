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
}
