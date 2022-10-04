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

enum ValidatorDetailSceneResult {
    case close
    case secondScan(ExtendedCBORWebToken)
    case startOver
}

private enum Constants {
     enum Keys {
         static let error_2G_unexpected_type_title = "error_2G_unexpected_type_title".localized
         static let error_2G_unexpected_type_copy = "error_2G_unexpected_type_copy".localized
         static let error_2G_unexpected_type_button = "error_2G_unexpected_type_button".localized
     }
 }

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
    
    func showMaskRequiredBusinessRules(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        let router = MaskRequiredResultRouter(sceneCoordinator: sceneCoordinator)
        return sceneCoordinator.present(MaskRequiredResultSceneFactory(router: router,
                                                                       reasonType: .functional,
                                                                       secondCertificateHintHidden: false,
                                                                       token: token),
                                        animated: true)
    }
    
    func showMaskRequiredBusinessRulesSecondScanAllowed(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        let router = MaskRequiredResultRouter(sceneCoordinator: sceneCoordinator)
        return sceneCoordinator.present(MaskRequiredResultSceneFactory(router: router,
                                                                       reasonType: .functional,
                                                                       secondCertificateHintHidden: false,
                                                                       token: token),
                                        animated: true)
    }
    
    func showMaskRequiredTechnicalError(token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        let router = MaskRequiredResultRouter(sceneCoordinator: sceneCoordinator)
        return sceneCoordinator.present(MaskRequiredResultSceneFactory(router: router,
                                                                       reasonType: .technical,
                                                                       secondCertificateHintHidden: true,
                                                                       token: token),
                                        animated: true)
    }
    
    func showMaskOptional(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        let router = MaskOptionalResultRouter(sceneCoordinator: sceneCoordinator)
        return sceneCoordinator.present(MaskOptionalResultSceneFactory(router: router,
                                                                       token: token),
                                        animated: true)
    }
    
    func showNoMaskRules(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        let router = NoMaskRulesResultRouter(sceneCoordinator: sceneCoordinator)
        return sceneCoordinator.present(NoMaskRulesResultSceneFactory(router: router,
                                                                      token: token),
                                        animated: true)
    }
    
    func showDifferentPerson(token1OfPerson: ExtendedCBORWebToken,
                             token2OfPerson: ExtendedCBORWebToken) -> Promise<DifferentPersonResult> {
        let view = DifferentPersonSceneFactory(firstResultCert: token1OfPerson.vaccinationCertificate,
                                               secondResultCert: token2OfPerson.vaccinationCertificate)
        return sceneCoordinator.present(view, animated: true)
    }
    
    func showSameCertType() {
        let copyString = Constants.Keys.error_2G_unexpected_type_copy
        showDialog(title: Constants.Keys.error_2G_unexpected_type_title,
                   message: copyString,
                   actions: [
                    DialogAction(title: Constants.Keys.error_2G_unexpected_type_button,
                                 style: UIAlertAction.Style.default,
                                 isEnabled: true,
                                 completion: nil)
                   ],
                   style: .alert)
    }
}
