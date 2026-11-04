import SwiftUI

@main
struct Application: App {

    @StateObject private var server = Webserver.instance
    @StateObject private var viewModel = FolderAccessViewModel.instance

    /// Uses a group rather than a single `Window`, which would quit the app
    /// when closed, cutting off a console still downloading. The Dock icon
    /// brings it back.
    var body: some Scene {
        WindowGroup {
            StartView()
        }
        .windowResizability(.contentSize)
        Settings {
            SettingsView()
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("Start server") {
                    Task {
                        do {
                            try await server.start()
                        } catch {
                            let dlg = NSAlert(error: error)
                            dlg.runModal()
                        }
                    }
                }.disabled(server.isRunning)
                Button("Stop server") { server.stop() }.disabled(
                    !server.isRunning
                )
            }
            CommandGroup(replacing: CommandGroupPlacement.appVisibility) {}
            CommandGroup(replacing: CommandGroupPlacement.systemServices) {}
        }
    }
}
