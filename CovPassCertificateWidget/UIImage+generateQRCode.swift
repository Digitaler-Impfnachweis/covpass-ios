import CoreImage.CIFilterBuiltins
import UIKit

extension UIImage {
    static func generateQRCode(from string: String) -> Self? {
        let data = Data(string.utf8)
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return Self(cgImage: cgimg)
            }
        }
        return nil
    }
}
