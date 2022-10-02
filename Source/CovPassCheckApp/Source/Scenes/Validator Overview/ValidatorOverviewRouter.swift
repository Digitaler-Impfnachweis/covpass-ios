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
    
    func showAppInformation(userDefaults: Persistence) {
        sceneCoordinator.push(
            AppInformationSceneFactory(
                router: AppInformationRouter(sceneCoordinator: sceneCoordinator),
                userDefaults: userDefaults
            )
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
        sceneCoordinator.push(CheckSituationResolvableSceneFactory(router: CheckSituationRouter(sceneCoordinator: sceneCoordinator),
                                                                   userDefaults: userDefaults))
    }

    func showNewRegulationsAnnouncement() -> PromiseKit.Promise<Void> {
        sceneCoordinator.present(NewRegulationsAnnouncementSceneFactory())
    }
    
    func routeToStateSelection() -> Promise<Void> {
        sceneCoordinator.present(StateSelectionSceneFactory(),
                                 animated: true)
    }
    
    func showMaskRequiredBusinessRules() -> Promise<Void> {
        let router = MaskRequiredResultRouter(sceneCoordinator: sceneCoordinator)
        return sceneCoordinator.present(MaskRequiredResultSceneFactory(router: router,
                                                                       reasonType: .functional,
                                                                       secondCertificateHintHidden: false),
                                        animated: true)
    }
    
    func showMaskRequiredBusinessRulesSecondScanAllowed(token: ExtendedCBORWebToken) -> Promise<Void> {
        let router = MaskRequiredResultRouter(sceneCoordinator: sceneCoordinator)
        return sceneCoordinator.present(MaskRequiredResultSceneFactory(router: router,
                                                                       reasonType: .functional,
                                                                       secondCertificateHintHidden: false),
                                        animated: true)
    }
    
    func showMaskRequiredTechnicalError() -> Promise<Void> {
        let router = MaskRequiredResultRouter(sceneCoordinator: sceneCoordinator)
        return sceneCoordinator.present(MaskRequiredResultSceneFactory(router: router,
                                                                       reasonType: .technical,
                                                                       secondCertificateHintHidden: true),
                                        animated: true)
    }
    
    func showMaskOptional(token: ExtendedCBORWebToken) -> Promise<Void> {
        let router = MaskOptionalResultRouter(sceneCoordinator: sceneCoordinator)
        return sceneCoordinator.present(MaskOptionalResultSceneFactory(router: router,
                                                                       token: token),
                                        animated: true)
    }
    
    func showNoMaskRules() -> Promise<Void> {
//        let router = NoMaskRulesResultRouter(sceneCoordinator: sceneCoordinator)
//        return sceneCoordinator.present(NoMaskRulesResultSceneFactory(
//            router: router,
//            token:
//        ), animated: true)
#warning("TODO: Add token")
        return .init(error: NSError(domain: "TODO", code: 0))
    }
}
