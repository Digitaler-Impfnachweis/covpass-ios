//
//  File.swift
//  
//
//  Created by Thomas Kuleßa on 09.03.22.
//

@testable import CovPassUI
import PDFKit
import PromiseKit
import XCTest

class RevocationPDFGeneratorMock: RevocationPDFGeneratorProtocol {
    var generateExpectation = XCTestExpectation(description: "generateExpectation")
    var error: Error?
    var pdfDocument = PDFDocument()
    var responseDelay: TimeInterval = 0.0

    func generate(with info: RevocationInfo) -> Promise<PDFDocument> {
        generateExpectation.fulfill()
        if let error = error {
            return after(seconds: responseDelay).then {
                Promise(error: error)
            }
        }
        return after(seconds: responseDelay).then {
            Promise.value(self.pdfDocument)
        }
    }
}
