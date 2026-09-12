import Foundation

/// Puts a shouted title back into title case.
enum GameTitleCasing {

    /// `title` in title case, when it arrived in block capitals.
    ///
    /// A title carrying any lower-case letter is left exactly as it is: the
    /// styling is deliberate there, and rewriting it would lose it.
    static func titleCased(_ title: String) -> String {
        guard !title.contains(where: \.isLowercase) else { return title }

        return
            title
            .split(separator: " ", omittingEmptySubsequences: false)
            .map { word in
                // Roman numerals are the one thing `capitalized` gets badly
                // wrong: "IV" comes back as "Iv".
                isRomanNumeral(String(word))
                    ? String(word) : String(word).capitalized
            }
            .joined(separator: " ")
    }

    /// Whether `word` is a Roman numeral.
    ///
    /// Checked by converting back, so that ordinary words built from the
    /// same letters — "DID", "CIVIC", "MILD" — are not mistaken for one.
    static func isRomanNumeral(_ word: String) -> Bool {
        guard !word.isEmpty else { return false }

        var total = 0
        var largest = 0
        for character in word.reversed() {
            guard let value = value(of: character) else { return false }
            total += value < largest ? -value : value
            largest = max(largest, value)
        }

        guard total > 0, total < 4000 else { return false }
        return roman(total) == word
    }

    private static func value(of character: Character) -> Int? {
        switch character {
        case "I": return 1
        case "V": return 5
        case "X": return 10
        case "L": return 50
        case "C": return 100
        case "D": return 500
        case "M": return 1000
        default: return nil
        }
    }

    private static let numerals: [(value: Int, symbol: String)] = [
        (1000, "M"), (900, "CM"), (500, "D"), (400, "CD"),
        (100, "C"), (90, "XC"), (50, "L"), (40, "XL"),
        (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I"),
    ]

    private static func roman(_ number: Int) -> String {
        var remaining = number
        var result = ""
        for (value, symbol) in numerals {
            while remaining >= value {
                result += symbol
                remaining -= value
            }
        }
        return result
    }
}
