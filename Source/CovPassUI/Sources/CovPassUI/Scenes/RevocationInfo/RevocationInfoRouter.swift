//
//  RevocationInfoRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PDFKit

struct RevocationInfoRouter: RevocationInfoRouterProtocol, RouterProtocol {
    let sceneCoordinator: SceneCoordinator

    func showPDFExport(with exportData: RevocationPDFExportDataProtocol) {
        sceneCoordinator.present(
            RevocationInfoPDFExportSceneFactory(exportData: exportData)
        )
    }
}
