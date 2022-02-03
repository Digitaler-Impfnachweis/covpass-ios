//
//  ValidatorOverviewRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import Scanner
import UIKit

class ValidatorOverviewRouter: ValidatorOverviewRouterProtocol {
    
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
                         _2GContext: Bool) {
        sceneCoordinator.present(
            ValidationResultSceneFactory(
                router: ValidationResultRouter(sceneCoordinator: sceneCoordinator),
                certificate: certificate,
                error: nil,
                _2GContext: _2GContext
            )
        )
    }
    
    func showAppInformation() {
        sceneCoordinator.push(
            AppInformationSceneFactory(
                router: AppInformationRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }
    
    func showError(error: Error,
                   _2GContext: Bool) {
        sceneCoordinator.present(
            ValidationResultSceneFactory(
                router: ValidationResultRouter(sceneCoordinator: sceneCoordinator),
                certificate: nil,
                error: error,
                _2GContext: _2GContext
            )
        )
    }
    
    func showGproof(initialToken: CBORWebToken,
                    repository: VaccinationRepositoryProtocol,
                    certLogic: DCCCertLogicProtocol) {
        sceneCoordinator.present(
            GProofSceneFactory(initialToken: initialToken,
                               router: GProofRouter(sceneCoordinator: sceneCoordinator),
                               repository: repository,
                               certLogic: certLogic)
        )
    }
}
