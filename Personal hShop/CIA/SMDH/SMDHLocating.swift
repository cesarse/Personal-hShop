/// Finds the SMDH block inside a CIA.
///
/// `CIAParser` tries its locators in order and takes the first offset one of
/// them returns, so another way of finding the block is another type here
/// rather than an edit to the parser.
protocol SMDHLocating {

    /// Absolute offset of the SMDH block, or `nil` when this strategy cannot
    /// find one.
    func locateSMDH(in reader: ByteReader, header: CIAHeader) throws -> UInt64?
}
