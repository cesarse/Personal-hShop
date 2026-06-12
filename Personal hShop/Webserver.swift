import Foundation
import SwiftUI
import Swifter

class Webserver: ObservableObject {

    @AppStorage("port") private var port: Int = 1234
    @AppStorage("openPage") private var openPage: Bool = false

    static let instance = Webserver()
    @Published var isRunning: Bool = false

    let server = HttpServer()
    private let bookmarkStore = BookmarkStore()

    private init() {
    }

    private func extractedFunc() {
        html {
            body {
                let ciaFiles: [String]
                do {
                    ciaFiles = try bookmarkStore.withSecurityScopedFolderAccess
                    { folderURL in
                        let allFiles = try FileManager.default
                            .contentsOfDirectory(atPath: folderURL.path)
                        return allFiles.filter { $0.hasSuffix(".cia") }
                    }
                } catch {
                    print("debug: failed to list files: \(error)")
                    ciaFiles = []
                }
                print("debug: ", ciaFiles)
                if ciaFiles.isEmpty {
                    h1 {
                        inner = "No .cia files found"
                    }
                } else {
                    ul {
                        for ciaFile in ciaFiles {
                            li {
                                a {
                                    href = ciaFile
                                    inner = ciaFile
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func start() throws {
        if isRunning { return }
        server["/"] = scopes {

            self.extractedFunc()

        }
        try server.start(UInt16(port), forceIPv4: true)
        print("debug: server started")
        isRunning = true
        if openPage, let url = URL(string: "http://localhost:\(port)") {
            NSWorkspace.shared.open(url)
        }
    }

    func stop() {
        if !isRunning { return }
        server.stop()
        print("debug: server stopped")
        isRunning = false
    }

}
