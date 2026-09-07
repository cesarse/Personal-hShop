import Foundation

/// The headers a `.cia` download is served with.
enum DownloadHeaders {

    static func serving(
        _ fileName: String,
        ofSize size: UInt64
    ) -> [String: String] {
        [
            "Content-Type": "application/octet-stream",
            "Content-Length": String(size),
            "Content-Disposition": contentDisposition(for: fileName),
            "Accept-Ranges": "none",
        ]
    }

    /// Quoted form for simple clients, RFC 5987 form for everything else.
    static func contentDisposition(for fileName: String) -> String {
        let quoted = fileName.replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\\", with: "")
        return
            "attachment; filename=\"\(quoted)\"; filename*=UTF-8''\(DownloadRoute.encoded(fileName))"
    }
}
