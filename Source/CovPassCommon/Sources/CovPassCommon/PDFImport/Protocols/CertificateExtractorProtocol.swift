//
//  PDFCBORConverterProtocol.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit

public typealias CertificateExtractorResults = [ExtendedCBORWebToken]

public protocol CertificateExtractorProtocol {
    /// Extracts QR code based CBOR web tokens from PDF document or images.
    /// - Parameters:
    ///   - document: Document to extract certificates from.
    ///   - ignoreTokens: Tokens equal to these tokens are ignored from extraction.
    /// - Returns: A list of tokens. The list does not contain revoked, expired, tokens which fail
    /// verification, revocation check or already existing one. The maximal number of tokens is limited to a
    /// configurable number.
    func extract(document: QRCodeDocumentProtocol, ignoreTokens: [ExtendedCBORWebToken]) -> Promise<CertificateExtractorResults>
}
