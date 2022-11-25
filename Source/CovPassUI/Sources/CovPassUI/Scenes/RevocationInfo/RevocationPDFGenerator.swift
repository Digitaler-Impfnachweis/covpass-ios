//
//  RevocationPDFGenerator.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PDFKit
import PromiseKit
import Security

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
    private let secKey: SecKey
    private lazy var isSVGTemplateValid =
        svgTemplate.contains(TemplateParameter.revocationCode) &&
        svgTemplate.contains(TemplateParameter.issuingCountry) &&
        svgTemplate.contains(TemplateParameter.expirationDate) &&
        svgTemplate.contains(TemplateParameter.qrCode)

    public init(converter: SVGToPDFConverterProtocol, jsonEncoder: JSONEncoder, svgTemplate: String, secKey: SecKey) {
        self.converter = converter
        self.svgTemplate = svgTemplate
        self.jsonEncoder = jsonEncoder
        self.secKey = secKey
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
        let multilineRevocationCode = encryptedAndBase64EncodedCode.svgTspans(
            nrOfCharacters: 55,
            yStart: 37,
            lineSpacing: 21
        )
        let revocationCode = (multilineRevocationCode, qrCode)
        return .value(revocationCode)
    }

    private func encryptAndBase64Encode(_ data: Data) -> String? {
        guard let encryptedData = try? data.encrypt(with: secKey, algoritm: .eciesEncryptionCofactorVariableIVX963SHA256AESGCM) else {
            return nil
        }
        return encryptedData.base64EncodedString()
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
