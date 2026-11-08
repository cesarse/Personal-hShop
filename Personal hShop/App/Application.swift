import SwiftUI

@main
struct Application: App {

    @StateObject private var server = Webserver.instance
    @StateObject private var viewModel = FolderAccessViewModel.instance

    /// Uses a group rather than a single `Window`, which would quit the app
    /// when closed, cutting off a console still downloading. The Dock icon
    /// and the Help menu bring it back, and its single value keeps it to one
    /// window.
    var body: some Scene {
        WindowGroup(id: StartWindow.id, for: StartWindow.self) { _ in
            StartView()
        } defaultValue: {
            StartWindow.shared
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
            CommandGroup(replacing: CommandGroupPlacement.help) {
                HelpButton()
            }
        }
    }
}
