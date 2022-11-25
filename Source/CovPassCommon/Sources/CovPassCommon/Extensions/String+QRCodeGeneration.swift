//
//  String+MakeQR.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

public extension String {
    func generateQRCode() -> UIImage? {
        let data = data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        return UIImage(ciImage: scaledQrImage)
    }
}
