import Foundation

/// How a `.cia` file is addressed over HTTP.
///
/// Both ends of the exchange need this: the index page builds the link a QR
/// code carries, and the download handler echoes the name back in a header.
enum DownloadRoute {

    /// Path prefix every download sits under.
    static let prefix = "/files"

    /// The route the server registers for downloads.
    static let pattern = "\(prefix)/:name"

    /// The absolute URL `fileName` is served from.
    static func url(base: String, fileName: String) -> String {
        base + prefix + "/" + encoded(fileName)
    }

    /// `fileName`, escaped so that it stays one path component.
    static func encoded(_ fileName: String) -> String {
        fileName.addingPercentEncoding(withAllowedCharacters: allowed)
            ?? fileName
    }

    /// The file name a download request asks for. The router hands the path
    /// segment over exactly as it arrived, still escaped by `encoded`, so it
    /// is decoded here, before anything checks or looks up the name.
    static func fileName(fromSegment segment: String) -> String? {
        segment.removingPercentEncoding
    }

    /// Characters that may appear unescaped in a single URL path component.
    /// `urlPathAllowed` permits "/", which would let a file name span
    /// several path segments, so it is removed here.
    private static let allowed: CharacterSet = {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/")
        return allowed
    }()
}
