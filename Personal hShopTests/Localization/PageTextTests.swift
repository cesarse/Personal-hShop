import Foundation
import Testing

@testable import Personal_hShop

struct PageTextTests {

    @Test("Serves an exactly requested language")
    func servesExactMatch() {
        let text = PageText(acceptLanguage: "fr")

        #expect(text.language == "fr")
        #expect(
            text.localized("No .cia files found") == "Aucun fichier .cia trouvé"
        )
    }

    @Test("Falls back from a region to the language we do have")
    func fallsBackAcrossRegions() {
        // Only pt-BR is bundled, so plain Portuguese should still land there.
        #expect(PageText(acceptLanguage: "pt").language == "pt-BR")
        #expect(PageText(acceptLanguage: "pt-PT").language == "pt-BR")
        // And a region we do not carry falls back to the base language.
        #expect(PageText(acceptLanguage: "fr-CA").language == "fr")
    }

    @Test("Honours the weights when choosing")
    func honoursWeights() {
        #expect(
            PageText(acceptLanguage: "ja;q=1.0, it;q=0.9, de;q=0.8").language
                == "it"
        )
    }

    @Test("Falls back when nothing was asked for or nothing matches")
    func fallsBackToTheApp() {
        let available = Set(Bundle.main.localizations)

        #expect(available.contains(PageText(acceptLanguage: nil).language))
        #expect(available.contains(PageText(acceptLanguage: "ja,ko").language))
    }

    @Test("Translates the interpolated instruction in every language")
    func translatesTheInstruction() {
        func instruction(_ tag: String) -> String {
            PageText(acceptLanguage: tag).localized(
                """
                In FBI, choose Remote Install → Scan QR Code, then point the \
                3DS at a code below. Available at \("http://10.0.0.1:1234").
                """
            )
        }

        let english = instruction("en")
        #expect(english.contains("Available at http://10.0.0.1:1234."))

        for tag in ["de", "es", "fr", "it", "pt-BR"] {
            let translated = instruction(tag)
            // A key that did not line up would silently return the English.
            #expect(translated != english, "\(tag) fell back to English")
            #expect(
                translated.contains("http://10.0.0.1:1234"),
                "\(tag) lost the address"
            )
            // FBI's own menu labels are not translated.
            #expect(translated.contains("Remote Install → Scan QR Code"))
        }
    }
}
