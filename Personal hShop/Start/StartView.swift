import SwiftUI

/// The window shown at launch and from the Help menu: the app's icon, name and
/// version, what the server is doing, and links to the support page, contact
/// the developer, review the app and read the privacy policy.
struct StartView: View {

    @StateObject private var server = Webserver.instance

    /// The address users write to, the same one on the support page.
    private static let supportEmail = URL(string: "mailto:personalhshop@icloud.com")!

    /// Opens the App Store's review sheet for the app.
    ///
    /// - ToDo: Replace the placeholder with the app's Apple ID from App Store
    ///   Connect.
    private static let reviewURL = URL(string: "https://apps.apple.com/app/id0000000000?action=write-review")!

    /// No fixed height: the window grows to fit the wrapped text.
    private static let windowWidth: CGFloat = 320

    /// A light tint over the window background, so it stays pale green in
    /// Light Mode and turns into a dark green in Dark Mode.
    private static let windowTint = Color.green.opacity(0.12)

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Personal hShop"
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    private var serverStatus: LocalizedStringKey {
        server.isRunning ? "The server is running." : "The server is stopped."
    }

    /// Long in some languages, so its text wraps instead of being truncated.
    private var serverInstruction: LocalizedStringKey {
        server.isRunning
            ? "Open the File menu and click Stop server."
            : "Open the File menu and click Start server."
    }

    var body: some View {
        VStack {
            VStack {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
                    .accessibilityHidden(true)
                Text(appName)
                    .font(.title)
                    .bold()
                Text("Version \(appVersion)")
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: HorizontalAlignment.leading, spacing: 8) {
                Text(serverStatus)
                Text(serverInstruction).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                    .frame(height: 1)
                Text("Need help?")
                Link("Support page", destination: OnlineDocument.support.url)
                Spacer()
                    .frame(height: 1)
                Text("Suggestions, problems?")
                Link("Send an e-mail", destination: Self.supportEmail)
                Spacer()
                    .frame(height: 1)
                Text("Love it, hate it?")
                Link("Review on the App Store", destination: Self.reviewURL)
                Spacer()
                    .frame(height: 1)
                Text("What about your data?")
                Link(
                    "Privacy Policy",
                    destination: OnlineDocument.privacyPolicy.url
                )
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: Self.windowWidth)
        .background(Self.windowTint)
    }
}

#Preview {
    StartView()
}
