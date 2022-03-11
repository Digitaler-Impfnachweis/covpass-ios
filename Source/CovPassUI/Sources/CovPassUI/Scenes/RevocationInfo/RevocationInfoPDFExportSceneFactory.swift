//
//  RevocationPDFExportSceneFactory.swift
//  
//
//  Created by Thomas Kuleßa on 09.03.22.
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
