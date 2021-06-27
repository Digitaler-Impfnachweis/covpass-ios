import SwiftUI

extension Image {
    static func generateQRCode(from string: String) -> Self? {
        guard let image = UIImage.generateQRCode(from: string) else {
            return nil
        }
        return .init(uiImage: image)
    }
}
