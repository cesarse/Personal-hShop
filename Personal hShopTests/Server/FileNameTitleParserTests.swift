import Testing

@testable import Personal_hShop

struct FileNameTitleParserTests {

    private let parser = FileNameTitleParser()

    @Test("Strips the title ID, the extension and the release detail")
    func parsesAFullReleaseName() {
        let name = "0004000000123400 Super Game (CTR-P-ABCD) (v1.0) (USA).cia"

        #expect(parser.title(from: name) == "Super Game")
    }

    @Test("Leaves a plain name alone")
    func keepsAPlainName() {
        #expect(parser.title(from: "Simple Game.cia") == "Simple Game")
    }

    @Test("Matches the extension whatever its case")
    func matchesExtensionCaseInsensitively() {
        #expect(parser.title(from: "Game.CIA") == "Game")
    }

    @Test("Only drops a leading 16-digit run that is really hexadecimal")
    func dropsOnlyHexTitleIDs() {
        #expect(parser.title(from: "ABCDEF0123456789 Name.cia") == "Name")
        #expect(
            parser.title(from: "notahexbutlong16 Name.cia")
                == "notahexbutlong16 Name"
        )
    }

    @Test("Keeps a bracketed group that is part of the title")
    func keepsNonMetadataGroups() {
        // Too long to be a region code, and not a version or product code.
        #expect(
            parser.title(from: "Game (Special Edition).cia")
                == "Game (Special Edition)"
        )
        #expect(parser.title(from: "Game (vABC).cia") == "Game (vABC)")
    }

    @Test("Recognises product codes, versions and regions as metadata")
    func recognisesReleaseMetadata() {
        #expect(parser.isReleaseMetadata("CTR-P-ABCD"))
        #expect(parser.isReleaseMetadata("KTR-N-XYZ"))
        #expect(parser.isReleaseMetadata("v1.2.3"))
        #expect(parser.isReleaseMetadata("USA"))
        #expect(parser.isReleaseMetadata("E"))
        #expect(!parser.isReleaseMetadata("Special Edition"))
        #expect(!parser.isReleaseMetadata("vABC"))
    }

    @Test("Trims the separators left behind by a removed group")
    func trimsTrailingSeparators() {
        #expect(
            parser.title(from: "Game - Subtitle (USA).cia")
                == "Game - Subtitle"
        )
    }

    @Test("Reports no title when nothing survives")
    func reportsNoTitle() {
        #expect(parser.title(from: "0004000000123400.cia") == nil)
        #expect(parser.title(from: ".cia") == nil)
        #expect(parser.title(from: "   .cia") == nil)
    }
}
