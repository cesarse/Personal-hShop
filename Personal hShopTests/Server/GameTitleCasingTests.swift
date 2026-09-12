import Testing

@testable import Personal_hShop

struct GameTitleCasingTests {

    @Test("Puts a shouted title into title case")
    func casesAShoutedTitle() {
        #expect(
            GameTitleCasing.titleCased("SONIC LOST WORLD") == "Sonic Lost World"
        )
    }

    @Test("Leaves Roman numerals alone")
    func keepsRomanNumerals() {
        #expect(
            GameTitleCasing.titleCased("SUPER STREET FIGHTER IV")
                == "Super Street Fighter IV"
        )
        #expect(
            GameTitleCasing.titleCased("DRAGON QUEST VIII")
                == "Dragon Quest VIII"
        )
    }

    @Test("Leaves a title that already has lower case exactly as it is")
    func respectsDeliberateStyling() {
        for title in [
            "Pokémon Ultra Sun", "Fire Emblem Awakening", "de Blob 2",
            "Kingdom Hearts ReMIX",
        ] {
            #expect(GameTitleCasing.titleCased(title) == title)
        }
    }

    @Test("Handles the punctuation real titles carry")
    func handlesPunctuation() {
        #expect(
            GameTitleCasing.titleCased("LUIGI'S MANSION 2")
                == "Luigi's Mansion 2"
        )
        #expect(
            GameTitleCasing.titleCased("NINTENDOGS + CATS")
                == "Nintendogs + Cats"
        )
        #expect(
            GameTitleCasing.titleCased("SUPER MARIO 3D LAND")
                == "Super Mario 3D Land"
        )
    }

    @Test("Recognises real Roman numerals")
    func recognisesNumerals() {
        for numeral in ["I", "II", "III", "IV", "V", "IX", "X", "XIII", "XV"] {
            #expect(GameTitleCasing.isRomanNumeral(numeral), "\(numeral)")
        }
    }

    @Test("Is not fooled by words built from the same letters")
    func rejectsLookalikes() {
        // Each of these is spelled entirely with numeral letters.
        for word in ["DID", "CIVIC", "MILD", "DIM", "LID", "IIII", "VV", "IC"] {
            #expect(!GameTitleCasing.isRomanNumeral(word), "\(word)")
        }
    }

    @Test("Leaves empty and blank input untouched")
    func handlesEmptyInput() {
        #expect(GameTitleCasing.titleCased("") == "")
        #expect(!GameTitleCasing.isRomanNumeral(""))
    }
}
