//
//  SVGToPDFConverterMock.swift
//  
//
//  Created by Thomas Kuleßa on 03.03.22.
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
