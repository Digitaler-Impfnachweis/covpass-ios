//
//  RevocationPDFExportSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PDFKit
import UIKit

struct RevocationInfoPDFExportSceneFactory: SceneFactory {
    private let exportData: RevocationPDFExportDataProtocol

    init(exportData: RevocationPDFExportDataProtocol) {
        self.exportData = exportData
    }

    func make() -> UIViewController {
        let viewModel = ShareRevocationPDFViewModel(exportData: exportData)
        let viewController = ShareRevocationPDFViewController(viewModel: viewModel)

        return viewController
    }
}
