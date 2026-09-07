import AppKit
import CoreImage.CIFilterBuiltins
import Foundation

/// Renders text as a QR code and returns it as an inline `data:` URI.
struct QRCode {

    /// Reused across requests: building a `CIContext` is expensive.
    private static let context = CIContext()

    /// The bitmap is one pixel per module and the page scales it up with
    /// `image-rendering: pixelated`, which keeps the modules crisp while
    /// keeping the embedded image small.
    func dataURI(for text: String) -> String? {
        guard let message = text.data(using: .utf8) else { return nil }

        let generator = CIFilter.qrCodeGenerator()
        generator.message = message
        // Lowest correction level keeps the module count down, which matters
        // for the 3DS camera: fewer, larger modules scan far more reliably
        // than a dense code, and a screen has no dirt to correct for.
        generator.correctionLevel = "L"

        guard let image = generator.outputImage,
            let cgImage = QRCode.context.createCGImage(
                image,
                from: image.extent
            )
        else {
            return nil
        }

        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        guard let png = bitmap.representation(using: .png, properties: [:])
        else {
            return nil
        }
        return "data:image/png;base64," + png.base64EncodedString()
    }
}
