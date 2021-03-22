//
// QRGeneratorView.swift
//  
//
// Copyright © 2021 IBM. All rights reserved.
//

import SwiftUI


struct QRGeneratorView: View {
    @State private var text = ""

    private let imageWidth: CGFloat
    private let imageHeight: CGFloat

    private let titleKey: LocalizedStringKey

    public init(imageWidth: CGFloat = 200, imageHeight: CGFloat = 200, titleKey: LocalizedStringKey = "Enter code") {
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.titleKey = titleKey
    }
    
    var body: some View {
        VStack {
            TextField(titleKey, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Image(uiImage: UIImage(data: getQRCodeData(text: text)!)!)
                .resizable()
                .frame(width: imageWidth, height: imageHeight)
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
}
