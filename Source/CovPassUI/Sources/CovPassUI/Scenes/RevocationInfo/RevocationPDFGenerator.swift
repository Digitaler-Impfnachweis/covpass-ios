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

public final class RevocationPDFGenerator: RevocationPDFGeneratorProtocol {
    private enum TemplateParameter {
        static let revocationCode = "$code"
        static let issuingCountry = "$co"
        static let expirationDate = "$te"
        static let qrCode = "$qr"
    }
    private typealias RevocationCode = (code: String, qr: String)
    private let converter: SVGToPDFConverterProtocol
    private let svgTemplate: String
    private let jsonEncoder: JSONEncoder
    private lazy var isSVGTemplateValid =
        svgTemplate.contains(TemplateParameter.revocationCode) &&
        svgTemplate.contains(TemplateParameter.issuingCountry) &&
        svgTemplate.contains(TemplateParameter.expirationDate) &&
        svgTemplate.contains(TemplateParameter.qrCode)

    public init(converter: SVGToPDFConverterProtocol, jsonEncoder: JSONEncoder, svgTemplate: String) {
        self.converter = converter
        self.svgTemplate = svgTemplate
        self.jsonEncoder = jsonEncoder
    }

    public func generate(with info: RevocationInfo) -> Promise<PDFDocument> {
        jsonEncoder
            .encodePromise(info)
            .then(prepareRevocationCode)
            .then { revocationCode, qrCode in
                self.fillInTemplate(
                    revocationCode: revocationCode,
                    expirationDate: info.technicalExpiryDate,
                    issuingCountry: info.issuingCountry,
                    qrCode: qrCode
                )
            }
            .then(converter.convert(_:))
    }

    private func prepareRevocationCode(_ data: Data) -> Promise<RevocationCode> {
        guard let encryptedAndBase64EncodedCode = encryptAndBase64Encode(data),
              let qrCode = base64EncodedQRCodeImage(encryptedAndBase64EncodedCode) else {
            return .init(error: RevocationPDFGeneratorError())
        }
        let revocationCode = (encryptedAndBase64EncodedCode, qrCode)
        return .value(revocationCode)
    }

    private func encryptAndBase64Encode(_ data: Data) -> String? {
        // TODO: Add encoding and encryption.
        return data.base64EncodedString()
    }

    private func base64EncodedQRCodeImage(_ qrCode: String) -> String? {
        qrCode.generateQRCode()?.pngData()?.base64EncodedString()
    }

    private func fillInTemplate(revocationCode: String, expirationDate: String, issuingCountry: String, qrCode: String) -> Promise<Data> {
        guard isSVGTemplateValid else {
            return .init(error: RevocationPDFGeneratorError())
        }
        let svg = svgTemplate
            .replacingOccurrences(of: TemplateParameter.revocationCode, with: revocationCode)
            .replacingOccurrences(of: TemplateParameter.expirationDate, with: expirationDate)
            .replacingOccurrences(of: TemplateParameter.issuingCountry, with: issuingCountry)
            .replacingOccurrences(of: TemplateParameter.qrCode, with: qrCode)
        guard let data = svg.data(using: .utf8) else {
            return .init(error: RevocationPDFGeneratorError())
        }

        return .value(data)
    }
}


