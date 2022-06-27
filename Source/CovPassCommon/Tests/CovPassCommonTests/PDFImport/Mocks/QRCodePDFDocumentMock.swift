//
//  QRCodePDFDocumentMock.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

struct QRCodePDFDocumentMock: QRCodeDocumentProtocol {
    var numberOfPages: Int {
        qrCodes.count
    }
    var qrCodes = [Set<String>]()
    var error: Error?

    func qrCodes(on page: Int) throws -> Set<String> {
        if let error = error {
            throw error
        }
        if page > numberOfPages {
            throw NSError(domain: "TEST", code: 1)
        }
        return qrCodes[page-1]
    }
}
