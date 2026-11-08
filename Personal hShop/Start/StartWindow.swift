/// The value the Start window shows. There is only one, so opening the window
/// again brings the open one to the front instead of adding a second.
enum StartWindow: String, Codable, Hashable {

    case shared

    static let id = "start"
}
