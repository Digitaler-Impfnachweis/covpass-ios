//
//  SVGToPDFConverterMock.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PDFKit
import PromiseKit

public final class SVGToPDFConverterMock: SVGToPDFConverterProtocol {
    var error: Error?
    var pdfDocument = PDFDocument()

    public init() {}

    public func convert(_ svgData: Data) -> Promise<PDFDocument> {
        if let error = self.error {
            return .init(error: error)
        }
        return .value(pdfDocument)
    }
}
