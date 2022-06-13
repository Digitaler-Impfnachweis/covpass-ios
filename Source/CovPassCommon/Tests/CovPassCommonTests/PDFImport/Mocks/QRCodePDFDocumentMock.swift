//
//  QRCodePDFDocumentMock.swift
//  
//
//  Created by Thomas Kuleßa on 10.06.22.
//

import CovPassCommon
import Foundation

struct QRCodePDFDocumentMock: QRCodePDFDocumentProtocol {
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
