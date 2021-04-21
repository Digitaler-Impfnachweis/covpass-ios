//
//  File.swift
//  
//
//  Created by Daniel on 16.04.2021.
//

import Foundation
import UIKit


extension String {
    func makeQr(size: CGSize) -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return  nil}
        qrFilter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        return UIImage(ciImage: scaledQrImage)
    }
}



