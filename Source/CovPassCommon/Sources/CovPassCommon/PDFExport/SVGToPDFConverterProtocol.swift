//
//  SVGToPDFConverterProtocol.swift
//  
//
//  Created by Thomas Kuleßa on 03.03.22.
//

import Foundation
import PromiseKit
import PDFKit

public protocol SVGToPDFConverterProtocol {
    /// Converts SVG to PDF.
    /// - Returns: A `Data` instance of a PDF file.
    func convert(_ svgData: Data) -> Promise<PDFDocument>
}

public struct SVGToPDFConverterError: Error {}
