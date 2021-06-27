import SwiftUI
import UIKit

struct CovPassCertificateWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    
    let entry: CovPassCertificateProvider.Entry

    var isSmall: Bool {
        family == .systemSmall
    }

    var body: some View {
        if let qrCode = entry.qrCode,
              let image = Image.generateQRCode(from: qrCode) {
            image
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .padding(isSmall ? 8 : 0)
                .background(Color.white)
        } else {
            Text("no_vaccination_favourite_selected")
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
