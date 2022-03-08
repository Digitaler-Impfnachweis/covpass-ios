//
//  RevocationPDFGeneratorProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PDFKit
import PromiseKit

protocol RevocationPDFGeneratorProtocol: AnyObject {
    func generate(with: RevocationPDFGeneratorContent) -> Promise<PDFDocument>
}

struct RevocationPDFGeneratorContent {
    let expirationDate: String
    let issuingCountry: String
    let qrCode: String
    let revocationCode: String
}

struct RevocationPDFGeneratorError: Error {}
