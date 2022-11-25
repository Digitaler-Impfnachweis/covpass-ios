//
//  QRCodeImageDocument.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import Vision

public final class QRCodeImagesDocument: QRCodeDocumentProtocol {
    public var numberOfPages: Int {
        images.count
    }

    private let images: [UIImage]
    private lazy var qrCodeDetectionRequest: VNDetectBarcodesRequest = {
        let request = VNDetectBarcodesRequest(completionHandler: nil)
        request.symbologies = [.QR]
        return request
    }()

    public init(images: [UIImage]) {
        self.images = images
    }

    public func qrCodes(on page: Int) throws -> Set<String> {
        guard numberOfPages > 0,
              1 ... numberOfPages ~= page,
              let cgImage = images[page - 1].cgImage else {
            throw QRCodePDFDocumentError.image
        }
        let qrCodesOnPage = try detectQRCodes(in: cgImage)

        return Set(qrCodesOnPage)
    }

    private func detectQRCodes(in image: CGImage) throws -> [String] {
        let requestHandler = VNImageRequestHandler(cgImage: image)
        try requestHandler.perform([qrCodeDetectionRequest])
        guard let observations = qrCodeDetectionRequest.results else {
            return []
        }
        let qrCodes = observations.map(\.payloadStringValue).compactMap { $0 }

        return qrCodes
    }
}
