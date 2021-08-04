//
//  SVGPDFExportProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PDFKit

public protocol SVGPDFExportProtocol {

    typealias SVGData = Data
    typealias ExportHandler = (_ export: PDFDocument?) -> Void

    /// Fill the given `Template` with the certificate data given.
    /// - Parameters:
    ///   - template: The template to fill
    ///   - token: The health certificate(s) to use in the template
    /// - Returns: `Data` representing a SVG String
    func fill(template: Template, with token: ExtendedCBORWebToken) throws -> SVGData?

    /// Exports the given data as PDF document, if possible.
    ///
    /// The export is realized via an private web view which does NOT allow Javascript execution!
    ///
    /// - Parameters:
    ///   - data: The data to export
    ///   - completion: Handler to contain an optional `PDFDocument`
    func export(_ data: SVGData, completion: ExportHandler?)

}
