//
//  GProofRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import Scanner
import UIKit

private enum Constants {
    enum Keys {
        static let error_2G_unexpected_type_title = "error_2G_unexpected_type_title".localized
        static let error_2G_unexpected_type_copy = "error_2G_unexpected_type_copy".localized
        static let error_2G_unexpected_type_button = "error_2G_unexpected_type_button".localized
    }
}

class GProofRouter: GProofRouterProtocol {

    // MARK: - Properties
    
    let sceneCoordinator: SceneCoordinator
    
    // MARK: - Lifecycle
    
    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }
    
    // MARK: - Methods
    
    func scanQRCode() -> Promise<ScanResult> {
        sceneCoordinator.present(
            ScanSceneFactory(
                cameraAccessProvider: CameraAccessProvider(
                    router: DialogRouter(sceneCoordinator: sceneCoordinator)
                )
            )
        )
    }
    
    func showCertificate(_ certificate: CBORWebToken?,
                         _2GContext: Bool,
                         userDefaults: Persistence) -> Promise<CBORWebToken> {
        sceneCoordinator.present(
            ValidationResultSceneFactory(
                router: ValidationResultRouter(sceneCoordinator: sceneCoordinator),
                certificate: certificate,
                error: nil,
                buttonHidden: true,
                _2GContext: _2GContext,
                userDefaults: userDefaults
            )
        )
    }
    
    func showError(error: Error) {
        let copyString = Constants.Keys.error_2G_unexpected_type_copy
        showDialog(title: Constants.Keys.error_2G_unexpected_type_title,
                   message: error.displayCodeWithMessage(copyString),
                   actions: [
                    DialogAction(title: Constants.Keys.error_2G_unexpected_type_button,
                                 style: UIAlertAction.Style.default,
                                 isEnabled: true,
                                 completion: nil)
                   ],
                   style: .alert)
    }
    
    func showDifferentPerson(firstResultCert: CBORWebToken,
                             scondResultCert: CBORWebToken) -> Promise<GProofResult> {
        sceneCoordinator.present(
            GProofDifferentPersonSceneFactory(firstResultCert: firstResultCert,
                                              secondResultCert: scondResultCert)
        )
    }
    
    func showStart() {
        
    }
}
