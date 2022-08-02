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
    
    func scanQRCode() -> Promise<QRCodeImportResult> {
        sceneCoordinator.present(
            ScanSceneFactory(
                cameraAccessProvider: CameraAccessProvider(
                    router: DialogRouter(sceneCoordinator: sceneCoordinator)
                ),
                router: ScanRouter(sceneCoordinator: sceneCoordinator),
                isDocumentPickerEnabled: false
            )
        )
    }
    
    func showCertificate(_ certificate: ExtendedCBORWebToken?,
                         _2GContext: Bool,
                         userDefaults: Persistence) {
        sceneCoordinator
            .present(
                ValidationResultSceneFactory(
                    router: ValidationResultRouter(sceneCoordinator: sceneCoordinator),
                    certificate: certificate,
                    error: nil,
                    _2GContext: _2GContext,
                    userDefaults: userDefaults
                )
            )
            .cauterize()
    }
    
    func showAppInformation(userDefaults: Persistence) {
        sceneCoordinator.push(
            AppInformationSceneFactory(
                router: AppInformationRouter(sceneCoordinator: sceneCoordinator),
                userDefaults: userDefaults
            )
        )
    }
    
    func showError(_ certificate: ExtendedCBORWebToken?,
                   error: Error,
                   _2GContext: Bool,
                   userDefaults: Persistence) -> Promise<ExtendedCBORWebToken>  {
        sceneCoordinator.present(
            ValidationResultSceneFactory(
                router: ValidationResultRouter(sceneCoordinator: sceneCoordinator),
                certificate: certificate,
                error: error,
                _2GContext: _2GContext,
                userDefaults: userDefaults
            )
        )
    }
    
    func showGproof(repository: VaccinationRepositoryProtocol,
                    revocationRepository: CertificateRevocationRepositoryProtocol,
                    certLogic: DCCCertLogicProtocol,
                    userDefaults: Persistence,
                    boosterAsTest: Bool) {
        sceneCoordinator
            .present(
                GProofSceneFactory(router: GProofRouter(sceneCoordinator: sceneCoordinator),
                                   repository: repository,
                                   revocationRepository: revocationRepository,
                                   certLogic: certLogic,
                                   userDefaults: userDefaults,
                                   boosterAsTest: boosterAsTest)
            )
            .cauterize()
    }
    
    func showCheckSituation(userDefaults: Persistence) -> Promise<Void> {
        sceneCoordinator.present(
            CheckSituationResolvableSceneFactory(contextType: .onboarding,
                                                 router: CheckSituationRouter(sceneCoordinator: sceneCoordinator),
                                                 userDefaults: userDefaults)
        )
    }

    func showDataPrivacy() -> Promise<Void> {
        sceneCoordinator.present(
            DataPrivacySceneFactory(
                router: DataPrivacyRouter(
                    sceneCoordinator: sceneCoordinator
                )
            )
        )
    }
    
    func routeToRulesUpdate(userDefaults: Persistence) -> Promise<Void> {
        sceneCoordinator.push(CheckSituationResolvableSceneFactory(contextType: .settings,
                                                                   router: CheckSituationRouter(sceneCoordinator: sceneCoordinator),
                                                                   userDefaults: userDefaults))
    }
}
