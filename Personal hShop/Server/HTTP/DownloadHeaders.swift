import Foundation
import Hummingbird

/// The headers a `.cia` download is served with.
enum DownloadHeaders {

    static func serving(
        _ fileName: String,
        ofSize size: UInt64
    ) -> HTTPFields {
        [
            .contentType: "application/octet-stream",
            .contentLength: String(size),
            .contentDisposition: contentDisposition(for: fileName),
            .acceptRanges: "none",
        ]
    }

    /// Quoted form for simple clients, RFC 5987 form for everything else.
    static func contentDisposition(for fileName: String) -> String {
        let quoted = fileName.replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\\", with: "")
        let encoded =
            fileName.addingPercentEncoding(withAllowedCharacters: attrChar)
            ?? fileName
        return
            "attachment; filename=\"\(quoted)\"; filename*=UTF-8''\(encoded)"
    }

    /// The only characters RFC 8187 lets through unescaped. A URL path
    /// allows more, and a ";" or "=" left as is would end the parameter, so
    /// "a;b.cia" would be saved as "a".
    private static let attrChar = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            + "abcdefghijklmnopqrstuvwxyz0123456789!#$&+-.^_`|~"
    )
}
