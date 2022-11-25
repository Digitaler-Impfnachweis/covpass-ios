//
//  SVGToPDFConverterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PDFKit
import PromiseKit

public protocol SVGToPDFConverterProtocol {
    /// Converts SVG to PDF.
    /// - Returns: A `Data` instance of a PDF file.
    func convert(_ svgData: Data) -> Promise<PDFDocument>
}

public struct SVGToPDFConverterError: Error {}
