//
//  PDFCBORConverterProtocol.swift
//  
//
//  Created by Thomas Kuleßa on 09.06.22.
//

import PromiseKit

typealias PDFCertificateExtractorResults = [ExtendedCBORWebToken]

protocol PDFCertificateExtractorProtocol {
    /// Extracts certificate QR codes from an underlying PDF document to CBOR web tokens.
    /// - Returns: A list of tokens. The list does not contain revoked, expired, tokens which fail
    /// verification, revocation check or already existing one. The maximal number of tokens is limited to a
    /// configurable number.
    func extract() -> Promise<PDFCertificateExtractorResults>
}
