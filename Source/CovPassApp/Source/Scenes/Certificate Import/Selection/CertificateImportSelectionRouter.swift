//
//  CertificateImportSelectionRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit

private enum Constants {
    static let errorTitle = "file_import_error_maximum_title".localized
    static let errorMessage = "file_import_error_maximum_copy".localized
    static let buttonText = "file_import_error_maximum_copy".localized
}

struct CertificateImportSelectionRouter: CertificateImportSelectionRouterProtocol, DialogRouterProtocol {
    let sceneCoordinator: SceneCoordinator

    func showTooManyHoldersError() {
        showDialog(
            title: Constants.errorTitle,
            message: Constants.errorMessage,
            actions: [DialogAction(title: Constants.buttonText)],
            style: .alert
        )
    }

    func showImportSuccess() -> Promise<Void> {
        sceneCoordinator.present(CertificateImportSuccessFactory())
    }
}
