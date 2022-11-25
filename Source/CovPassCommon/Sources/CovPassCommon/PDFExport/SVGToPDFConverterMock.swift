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

    public func convert(_: Data) -> Promise<PDFDocument> {
        if let error = error {
            return .init(error: error)
        }
        return .value(pdfDocument)
    }
}
