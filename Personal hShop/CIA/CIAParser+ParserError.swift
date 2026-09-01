extension CIAParser {
    enum ParserError: Error {
        case invalidHeader
        case cannotRead
        case smdhNotFound
    }
}
