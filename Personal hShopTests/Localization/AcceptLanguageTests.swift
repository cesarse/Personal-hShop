import Testing

@testable import Personal_hShop

struct AcceptLanguageTests {

    @Test("Reads a plain list in the order it was written")
    func readsPlainList() {
        #expect(AcceptLanguage(header: "de,it").preferences == ["de", "it"])
    }

    @Test("Orders by weight, heaviest first")
    func ordersByWeight() {
        #expect(
            AcceptLanguage(header: "de;q=0.5, it;q=0.9").preferences
                == ["it", "de"]
        )
        // A tag with no weight is fully wanted, so it outranks q=0.9.
        #expect(
            AcceptLanguage(header: "it;q=0.9,de").preferences == ["de", "it"]
        )
    }

    @Test("Keeps header order when weights are equal")
    func keepsOrderOnTies() {
        #expect(
            AcceptLanguage(header: "fr;q=0.8,de;q=0.8,it;q=0.8").preferences
                == ["fr", "de", "it"]
        )
    }

    @Test("Normalises case and whitespace")
    func normalises() {
        #expect(
            AcceptLanguage(header: "  FR-CH , EN ; q=0.5 ").preferences
                == ["fr-ch", "en"]
        )
    }

    @Test("Drops the wildcard, which the fallback already covers")
    func dropsWildcard() {
        #expect(
            AcceptLanguage(header: "fr,*;q=0.5").preferences == ["fr"]
        )
    }

    @Test("Reports nothing when the header is absent or empty")
    func handlesNoHeader() {
        #expect(AcceptLanguage(header: nil).preferences.isEmpty)
        #expect(AcceptLanguage(header: "").preferences.isEmpty)
    }
}
