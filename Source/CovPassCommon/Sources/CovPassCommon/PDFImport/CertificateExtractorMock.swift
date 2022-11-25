//
//  PDFCertificateExtractorMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public class CertificateExtractorMock: CertificateExtractorProtocol {
    public var extractionResult: [ExtendedCBORWebToken] = []
    public var receivedDocument: QRCodeDocumentProtocol?
    public var receivedTokens: [ExtendedCBORWebToken]?
    public var error: Error?

    public init() {}

    public func extract(document: QRCodeDocumentProtocol, ignoreTokens: [ExtendedCBORWebToken]) -> Promise<CertificateExtractorResults> {
        receivedDocument = document
        receivedTokens = ignoreTokens
        if let error = error {
            return .init(error: error)
        }
        return .value(extractionResult)
    }
}
