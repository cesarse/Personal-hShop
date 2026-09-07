import Testing

@testable import Personal_hShop

struct GameTitleResolverTests {

    @Test("Stops at the null padding an SMDH slot carries")
    func dropsNullPadding() {
        #expect(GameTitleResolver.sanitized("Zelda\0\0\0") == "Zelda")
        #expect(GameTitleResolver.sanitized("Zelda\0Trailing") == "Zelda")
    }

    @Test("Folds a wrapped title onto one line")
    func foldsLineBreaks() {
        #expect(
            GameTitleResolver.sanitized("Super\nGame") == "Super Game"
        )
    }

    @Test("Trims the surrounding whitespace")
    func trimsWhitespace() {
        #expect(GameTitleResolver.sanitized("  Game  ") == "Game")
    }
}
