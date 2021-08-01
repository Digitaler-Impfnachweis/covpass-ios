//
//  PDFExportViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit
import UIKit

class PDFExportViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let token: ExtendedCBORWebToken
    let resolver: Resolver<Void>

    var title: String {
        "certificate_pdf_export_overview_title".localized
    }

    var exportButtonTitle: String {
        "certificate_pdf_export_export_button_title".localized
    }

    // MARK: - Lifecycle

    init(
        token: ExtendedCBORWebToken,
        resolvable: Resolver<Void>
    ) {
        self.token = token
        resolver = resolvable
    }

    func generatePDF(completion: @escaping SVGPDFExporter.ExportHandler) {
        let exporter = SVGPDFExporter()
        guard
            let template = exporter.loadTemplate(for: token),
            let svgData = exporter.fill(template: template, with: token)
        else {
            completion(nil)
            return
        }

        exporter.export(svgData) { document in
            completion(document)
        }
    }

    func cancel() {
        resolver.cancel()
    }
}
