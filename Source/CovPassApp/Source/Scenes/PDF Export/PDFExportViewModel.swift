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

class PDFExportViewModel: PDFExportViewModelProtocol, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let token: ExtendedCBORWebToken
    let resolver: Resolver<Void>

    // lazy reference to exporter (and it's web view)
    private lazy var exporter = SVGPDFExporter()

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
        guard
            let template = token.vaccinationCertificate.hcert.dgc.template,
            let svgData = try? exporter.fill(template: template, with: token)
        else {
            completion(nil)
            return
        }

        exporter.export(svgData) { document in
            DispatchQueue.main.async {
                completion(document)
            }
        }
    }

    func cancel() {
        resolver.cancel()
    }
}
