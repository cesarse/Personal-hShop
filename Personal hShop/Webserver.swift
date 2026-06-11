import Foundation
import SwiftUI
import Swifter

class Webserver: ObservableObject {

  @AppStorage("rootFolder") private var rootFolder: String = ""
  @AppStorage("port") private var port: Int = 1234
  @AppStorage("openPage") private var openPage: Bool = false

  static let instance = Webserver()
  @Published var isRunning: Bool = false

  let server = HttpServer()

  private init() {
  }

  private func extractedFunc() {
    html {
      body {
        for i in 1...5 {
          h1 {
            inner = "Hello, world " + String(i)
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
    try server.start(UInt16(port))
    print("server started")
    isRunning = true
    if openPage, let url = URL(string: "http://localhost:\(port)") {
      NSWorkspace.shared.open(url)
    }
  }

  func stop() {
    if !isRunning { return }
    server.stop()
    print("server stopped")
    isRunning = false
  }

}
