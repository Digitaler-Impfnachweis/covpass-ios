//
//  PDFExportViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

protocol PDFExportViewModelProtocol {
    func generatePDF(completion: @escaping SVGPDFExporter.ExportHandler)
}
