//
//  RevocationInfoRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PDFKit

public struct RevocationInfoRouter: RevocationInfoRouterProtocol, RouterProtocol {
    public let sceneCoordinator: SceneCoordinator

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    public func showPDFExport(with exportData: RevocationPDFExportDataProtocol) {
        sceneCoordinator.present(
            RevocationInfoPDFExportSceneFactory(exportData: exportData)
        )
    }
}
