import SwiftUI

struct SettingsView: View {

  @AppStorage("rootFolder") private var rootFolder: String = ""
  @AppStorage("port") private var port: Int = 1234
  @AppStorage("openPage") private var openPage: Bool = false

  @State private var showChooseFolderDialog: Bool = false
  @StateObject private var server = Webserver.instance

  var body: some View {
      Form {
          if server.isRunning {
              HStack {
                  Label("Stop the server to change settings.", systemImage: "exclamationmark.triangle").symbolRenderingMode(.multicolor)
                  Button(
                    action: { server.stop() },
                    label: { Label("Stop", systemImage: "stop.circle").symbolRenderingMode(.multicolor) }
                  )
              }
          }
          Section {
              HStack {
                  let userHome: String = FileManager.default.homeDirectoryForCurrentUser.relativePath
                  TextField(".CIA folder:", text: $rootFolder, prompt: Text(userHome))
                      .truncationMode( /*@START_MENU_TOKEN@*/.tail /*@END_MENU_TOKEN@*/).help(rootFolder)
                  Button(
                    action: { showChooseFolderDialog = true },
                    label: { Label("Choose folder...", systemImage: "folder") }
                  )
                  .fileImporter(
                    isPresented: $showChooseFolderDialog, allowedContentTypes: [.folder],
                    onCompletion: { result in
                        try! rootFolder = result.get().relativePath
                    }
                  )
              }
              HStack {
                  TextField(
                    "Server port:", value: $port, format: .number.grouping(.never), prompt: Text("1234")
                  )
                  Spacer().padding(.horizontal)
              }
              Toggle("Automatically open page after server starts", isOn: $openPage).toggleStyle(.automatic)
          }.disabled(server.isRunning)
      }.padding().frame(minWidth: 400, maxWidth: 600)
  }
}

#Preview {
    SettingsView()
}
