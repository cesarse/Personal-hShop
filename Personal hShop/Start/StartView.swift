import SwiftUI

/// The window shown at launch: the app's icon, name and version, what the
/// server is doing, and links to contact the developer, review the app and
/// read the privacy policy.
struct StartView: View {

    @StateObject private var server = Webserver.instance

    /// The address users write to, the same one on the support page.
    private static let supportEmail = URL(string: "mailto:personalhshop@icloud.com")!

    /// Opens the App Store's review sheet for the app.
    // TODO: Replace the placeholder with the app's Apple ID from App Store Connect.
    private static let reviewURL = URL(string: "https://apps.apple.com/app/id0000000000?action=write-review")!

    /// Apple requires a link to the privacy policy inside the app.
    private static let privacyPolicyURL = URL(string: "https://github.com/cesarse/Personal-hShop/blob/main/PRIVACY.md")!

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Personal hShop"
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    private var serverStatus: LocalizedStringKey {
        server.isRunning
            ? "The server is running.\nOpen the File menu and click Stop server."
            : "The server is stopped.\nOpen the File menu and click Start server."
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
                Spacer()
                    .frame(height: 1)
            }
            VStack(alignment: HorizontalAlignment.leading, spacing: 8) {
                Text(serverStatus)
                    .multilineTextAlignment(.center)
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
                Link("Privacy Policy", destination: Self.privacyPolicyURL)
            }
            .padding()
        }
        .frame(width: 320, height: 440)
        // A light tint over the window background, so it stays pale green in
        // Light Mode and turns into a dark green in Dark Mode.
        .background(Color.green.opacity(0.12))
    }
}

#Preview {
    StartView()
}
