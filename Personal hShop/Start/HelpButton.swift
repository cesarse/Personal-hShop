import SwiftUI

/// The Help menu's item. The app has no help book, so it brings up the Start
/// window, which says how to start the server and where to find support.
struct HelpButton: View {

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Personal hShop Help") {
            openWindow(id: StartWindow.id, value: StartWindow.shared)
        }
        .keyboardShortcut("?")
    }
}
