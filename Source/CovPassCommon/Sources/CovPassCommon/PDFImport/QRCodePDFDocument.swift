//
//  File.swift
//  
//
//  Created by Thomas Kuleßa on 09.06.22.
//

import CoreGraphics
import Foundation
import UIKit
import Vision

public final class QRCodePDFDocument: QRCodeDocumentProtocol {
    public let numberOfPages: Int

    private let document: CGPDFDocument
    private lazy var qrCodeDetectionRequest: VNDetectBarcodesRequest = {
        let request = VNDetectBarcodesRequest(completionHandler: nil)
        request.symbologies = [.QR]
        return request
    }()

    public init(with url: URL) throws {
        let data = try Data(contentsOf: url)
        guard let dataProvider = CGDataProvider(data: NSData(data: data)),
              let document = CGPDFDocument(dataProvider) else {
            throw QRCodePDFDocumentError.file(url)
        }
        self.document = document
        numberOfPages = document.numberOfPages
    }

    public func qrCodes(on page: Int) throws -> Set<String> {
        guard let page = document.page(at: page) else {
            throw QRCodePDFDocumentError.pageNumber(page)
        }
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let pageImage = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }
        guard let pageCGImage = pageImage.cgImage else {
            throw QRCodePDFDocumentError.image
        }
        let qrCodesOnPage = try detectQRCodes(in: pageCGImage)

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
