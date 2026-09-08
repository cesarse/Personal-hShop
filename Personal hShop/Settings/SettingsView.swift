import SwiftUI

struct SettingsView: View {

    @AppStorage("port") private var port: Int = 1234
    @AppStorage("openPage") private var openPage: Bool = false

    @State private var showChooseFolderDialog: Bool = false
    @StateObject private var server = Webserver.instance
    @StateObject private var viewModel = FolderAccessViewModel.instance

    var body: some View {
        Form {
            if server.isRunning {
                HStack {
                    Label(
                        "Stop the server to change settings.",
                        systemImage: "exclamationmark.triangle"
                    ).symbolRenderingMode(.multicolor)
                    Button(
                        action: { server.stop() },
                        label: {
                            Label("Stop", systemImage: "stop.circle")
                                .symbolRenderingMode(.multicolor)
                        }
                    )
                }
            }
            Section {
                HStack {
                    TextField(
                        ".CIA folder:",
                        text: .constant(viewModel.folderPath ?? ""),
                        prompt: Text("No folder selected")
                    )
                    .textFieldStyle(.plain)
                    .disabled(true)
                    .truncationMode(.tail)
                    .help(viewModel.folderPath ?? "")
                    Button(
                        action: { showChooseFolderDialog = true },
                        label: {
                            Label("Choose folder…", systemImage: "folder")
                        }
                    )
                    .fileImporter(
                        isPresented: $showChooseFolderDialog,
                        allowedContentTypes: [.folder],
                        allowsMultipleSelection: false,
                        onCompletion: { result in
                            viewModel.handleFolderImport(result)
                        }
                    )

                }
                HStack {
                    TextField(
                        "Server port:",
                        value: $port,
                        format: .number.grouping(.never),
                        prompt: Text(verbatim: "1234")
                    )
                    Spacer().padding(.horizontal)
                }
                Toggle(
                    "Automatically open page after server starts",
                    isOn: $openPage
                ).toggleStyle(.automatic)
            }.disabled(server.isRunning)
        }.padding().frame(minWidth: 400, maxWidth: 600)
    }
}

#Preview {
    SettingsView()
}
