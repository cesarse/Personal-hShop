import SwiftUI

@main
struct Application: App {

  @StateObject private var server = Webserver.instance

  var body: some Scene {
    Settings {
      SettingsView()
    }
    .commands {
      CommandGroup(replacing: CommandGroupPlacement.newItem) {
        Button("Start server") {
          do {
            try server.start()
          } catch {
            let dlg = NSAlert(error: error)
            dlg.runModal()
          }
        }.disabled(server.isRunning)
        Button("Stop server") { server.stop() }.disabled(!server.isRunning)
      }
      CommandGroup(replacing: CommandGroupPlacement.saveItem) {}
      CommandGroup(replacing: CommandGroupPlacement.appVisibility) {}
      CommandGroup(replacing: CommandGroupPlacement.systemServices) {}
    }
  }
}
