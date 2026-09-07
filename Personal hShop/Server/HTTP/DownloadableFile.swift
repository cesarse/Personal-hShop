import Foundation

/// A `.cia` in the shared folder, open and ready to stream.
struct DownloadableFile {

    let handle: FileHandle
    let size: UInt64

    /// Opens `fileName` inside the folder the user shared.
    ///
    /// The descriptor is opened while access is still granted, so it stays
    /// readable once the scope is released and the body is streamed.
    init(named fileName: String, in bookmarkStore: BookmarkStore) throws {
        (handle, size) = try bookmarkStore.withSecurityScopedFolderAccess {
            folderURL -> (FileHandle, UInt64) in
            let fileURL = folderURL.appendingPathComponent(fileName)
            try DownloadableFile.checkSitsDirectlyIn(folderURL, fileURL)
            let size = try DownloadableFile.regularFileSize(at: fileURL)
            return (try FileHandle(forReadingFrom: fileURL), size)
        }
    }

    /// Belt and braces: the resolved file has to sit directly inside the
    /// folder the user actually shared.
    private static func checkSitsDirectlyIn(
        _ folderURL: URL,
        _ fileURL: URL
    ) throws {
        guard
            fileURL.deletingLastPathComponent().standardizedFileURL.path
                == folderURL.standardizedFileURL.path
        else {
            throw DownloadError.unavailable
        }
    }

    private static func regularFileSize(at fileURL: URL) throws -> UInt64 {
        let attributes = try FileManager.default.attributesOfItem(
            atPath: fileURL.path
        )
        guard
            attributes[.type] as? FileAttributeType == .typeRegular,
            let size = attributes[.size] as? UInt64
        else {
            throw DownloadError.unavailable
        }
        return size
    }
}
