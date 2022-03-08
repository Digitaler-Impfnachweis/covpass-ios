//
//  RevocationPDFGenerator.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import CovPassCommon
import PDFKit

final class RevocationPDFGenerator: RevocationPDFGeneratorProtocol {
    private enum TemplateParameter {
        static let revocationCode = "$code"
        static let issuingCountry = "$co"
        static let expirationDate = "$te"
        static let qrCode = "$qr"
    }
    private let converter: SVGToPDFConverterProtocol
    private let svgTemplate: String
    private lazy var isSVGTemplateValid =
        svgTemplate.contains(TemplateParameter.revocationCode) &&
        svgTemplate.contains(TemplateParameter.issuingCountry) &&
        svgTemplate.contains(TemplateParameter.expirationDate) &&
        svgTemplate.contains(TemplateParameter.qrCode)

    init(converter: SVGToPDFConverterProtocol, svgTemplate: String) {
        self.converter = converter
        self.svgTemplate = svgTemplate
    }

    func generate(with content: RevocationPDFGeneratorContent) -> Promise<PDFDocument> {
        fillInTemplate(with: content)
            .then(converter.convert(_:))
    }

    private func fillInTemplate(with content: RevocationPDFGeneratorContent) -> Promise<Data> {
        guard isSVGTemplateValid,
              let base64EncodedQRCodePNG = content.qrCode.generateQRCode()?.pngData()?.base64EncodedString() else {
            return .init(error: RevocationPDFGeneratorError())
        }
        let svg = svgTemplate
            .replacingOccurrences(of: TemplateParameter.revocationCode, with: content.revocationCode)
            .replacingOccurrences(of: TemplateParameter.expirationDate, with: content.expirationDate)
            .replacingOccurrences(of: TemplateParameter.issuingCountry, with: content.issuingCountry)
            .replacingOccurrences(of: TemplateParameter.qrCode, with: base64EncodedQRCodePNG)
        guard let data = svg.data(using: .utf8) else {
            return .init(error: RevocationPDFGeneratorError())
        }

        return .value(data)
    }
}


