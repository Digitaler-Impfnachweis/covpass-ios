//
//  PDFExportViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit
import UIKit

public class PDFExportViewModel: PDFExportViewModelProtocol, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let token: ExtendedCBORWebToken
    let resolver: Resolver<Void>

    private let exporter: SVGPDFExportProtocol

    var title: String {
        "certificate_create_pdf_headline".localized(bundle: .main)
    }

    var exportButtonTitle: String {
        "certificate_create_pdf_list_button".localized(bundle: .main)
    }

    var disclaimerText: NSAttributedString {
        NSAttributedString().appendBullets([
            NSAttributedString(string: "certificate_create_pdf_first_list_item".localized(bundle: .main)),
            NSAttributedString(string: "certificate_create_pdf_second_list_item".localized(bundle: .main)),
            NSAttributedString(string: "certificate_create_pdf_third_list_item".localized(bundle: .main))
        ])
    }

    // MARK: - Lifecycle

    public init(
        token: ExtendedCBORWebToken,
        resolvable: Resolver<Void>,
        exporter: SVGPDFExportProtocol
    ) {
        self.token = token
        resolver = resolvable
        self.exporter = exporter
    }

    public func generatePDF(completion: @escaping SVGPDFExporter.ExportHandler) {
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

    public func cancel() {
        resolver.cancel()
    }
}
