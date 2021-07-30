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

    func generatePDF() {

        print("TODO: PDF generation")
        //resolver.fulfill_()
    }

    func cancel() {
        resolver.cancel()
    }
}
