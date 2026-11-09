import Foundation
import Testing

@testable import Personal_hShop

struct OnlineDocumentTests {

    @Test("English opens the page with the plain name")
    func englishKeepsThePlainName() {
        #expect(
            OnlineDocument.support.url(in: "en").absoluteString
                == "https://github.com/cesarse/Personal-hShop/blob/main/SUPPORT.md"
        )
        #expect(
            OnlineDocument.privacyPolicy.url(in: "en").lastPathComponent
                == "PRIVACY.md"
        )
    }

    @Test("A translated language opens its own page")
    func translationAddsTheLanguage() {
        #expect(
            OnlineDocument.support.url(in: "pt-BR").lastPathComponent
                == "SUPPORT-pt-BR.md"
        )
        #expect(
            OnlineDocument.privacyPolicy.url(in: "fr").lastPathComponent
                == "PRIVACY-fr.md"
        )
    }

    @Test("A language without pages falls back to English")
    func untranslatedFallsBack() {
        #expect(
            OnlineDocument.support.url(in: "ja").lastPathComponent
                == "SUPPORT.md"
        )
    }

    @Test("Every language the app ships has its own pages")
    func everyLocalizationIsTranslated() {
        // A language added to the app without translated pages would quietly
        // send its users to English.
        let languages = Bundle.main.localizations.filter {
            $0 != "en" && $0 != "Base"
        }
        #expect(!languages.isEmpty)
        for language in languages {
            #expect(
                OnlineDocument.support.url(in: language).lastPathComponent
                    == "SUPPORT-\(language).md"
            )
            #expect(
                OnlineDocument.privacyPolicy.url(in: language).lastPathComponent
                    == "PRIVACY-\(language).md"
            )
        }
    }
}
