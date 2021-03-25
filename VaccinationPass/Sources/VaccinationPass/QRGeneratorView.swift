//
// QRGeneratorView.swift
//  
//
// Copyright © 2021 IBM. All rights reserved.
//

import SwiftUI

struct QRGeneratorView: View {
    @State private var text = ""

    private let titleKey: LocalizedStringKey

    public init(titleKey: LocalizedStringKey = "Enter code") {
        self.titleKey = titleKey
    }
    
    var body: some View {
        VStack {
            TextField(titleKey, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Image(uiImage: getQRCodeImage(from: text))
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
    
    func getQRCodeData(text: String) -> Data? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let data = text.data(using: .ascii, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        guard let ciimage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciimage.transformed(by: transform)
        let uiimage = UIImage(ciImage: scaledCIImage)
        return uiimage.pngData()
    }

    func getQRCodeImage(from text: String) -> UIImage {
        guard let data = getQRCodeData(text: text), let qrImage = UIImage(data: data) else { return UIImage() }
        return qrImage
    }
}

struct QRGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        QRGeneratorView()
            .frame(width: 400, height: 400)
    }
}
