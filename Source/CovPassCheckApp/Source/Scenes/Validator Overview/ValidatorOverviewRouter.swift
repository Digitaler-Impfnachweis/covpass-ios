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

enum ValidatorDetailSceneResult: Equatable {
    case close
    case secondScan(ExtendedCBORWebToken)
    case thirdScan(ExtendedCBORWebToken, ExtendedCBORWebToken)
    case startOver
}

private enum Constants {
     enum Keys {
         static let error_2G_unexpected_type_title = "error_2G_unexpected_type_title".localized
         static let error_2G_unexpected_type_copy = "error_2G_unexpected_type_copy".localized
         static let error_2G_unexpected_type_button = "error_2G_unexpected_type_button".localized

         static let infschg_name_matching_error_title = "infschg_name_matching_error_title".localized
         static let infschg_name_matching_error_copy = "infschg_name_matching_error_copy".localized
         static let infschg_name_matching_error_retry = "infschg_name_matching_error_retry".localized
         static let infschg_name_matching_error_cancel = "infschg_name_matching_error_cancel".localized
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
    
    func showNewRegulationsAnnouncement() -> Promise<Void> {
        sceneCoordinator.present(NewRegulationsAnnouncementSceneFactory())
    }
    
    func routeToStateSelection() -> Promise<Void> {
        sceneCoordinator.present(StateSelectionSceneFactory(),
                                 animated: true)
    }

    func routeToRulesUpdate(userDefaults: Persistence) -> Promise<Void> {
         sceneCoordinator.push(
            CheckSituationResolvableSceneFactory(
                router: CheckSituationRouter(sceneCoordinator: sceneCoordinator),
                userDefaults: userDefaults
            )
         )
     }
    
    func routeToChooseCheckSituation() -> Promise<Void> {
        let router = ChooseCheckSituationRouter(sceneCoordinator: sceneCoordinator)
        let factory = ChooseCheckSituationSceneFactory(router: router)
        return sceneCoordinator.present(factory, animated: true)
    }
    
    // MARK: Mask Check

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
    
    func showMaskCheckDifferentPerson(token1OfPerson: ExtendedCBORWebToken,
                             token2OfPerson: ExtendedCBORWebToken) -> Promise<DifferentPersonResult> {
        let view = DifferentPersonSceneFactory(firstResultCert: token1OfPerson.vaccinationCertificate,
                                               secondResultCert: token2OfPerson.vaccinationCertificate)
        return sceneCoordinator.present(view, animated: true)
    }
    
    func showMaskCheckSameCertType() {
        showDialog(
            title: Constants.Keys.error_2G_unexpected_type_title,
            message: Constants.Keys.error_2G_unexpected_type_copy,
            actions: [
            DialogAction(title: Constants.Keys.error_2G_unexpected_type_button,
                 style: UIAlertAction.Style.default,
                 isEnabled: true,
                 completion: nil)
            ],
            style: .alert
        )
    }
    
    // MARK: Ifsg22a Check

    func showVaccinationCycleComplete(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        let router = VaccinationCycleCompleteResultRouter(sceneCoordinator: sceneCoordinator)
        let view = VaccinationCycleCompleteResultSceneFactory(router: router,
                                                              token: token)
        return sceneCoordinator.present(view, animated: true)
    }

    func showIfsg22aCheckDifferentPerson(token1OfPerson: ExtendedCBORWebToken, token2OfPerson: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        Promise { seal in
            showDialog(
                title: Constants.Keys.infschg_name_matching_error_title,
                message: Constants.Keys.infschg_name_matching_error_copy,
                actions: [
                    DialogAction(
                        title: Constants.Keys.infschg_name_matching_error_retry,
                        style: UIAlertAction.Style.default,
                        isEnabled: true,
                        completion: { _ in
                            seal.fulfill(.secondScan(token1OfPerson))
                        }
                    ),
                    DialogAction(
                        title: Constants.Keys.infschg_name_matching_error_cancel,
                        style: UIAlertAction.Style.default,
                        isEnabled: true,
                        completion: { _ in
                            seal.fulfill(.close)
                        }
                    ),
                ],
                style: .alert
            )
        }
    }
    
    func showIfsg22aNotComplete(token: ExtendedCBORWebToken, secondToken: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        let view = SecondScanSceneFactory(token: token,
                                          secondToken: secondToken)
        return sceneCoordinator.present(view, animated: true)
    }
    
    func showIfsg22aCheckError(token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        let router = CertificateInvalidResultRouter(sceneCoordinator: sceneCoordinator)
        let view = CertificateInvalidResultSceneFactory(router: router,
                                                        token: token)
        return sceneCoordinator.present(view, animated: true)
    }
    
    func showIfsg22aIncompleteResult(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        let view = VaccinationCycleIncompleteResultSceneFactory(router: VaccinationCycleIncompleteResultRouter(sceneCoordinator: sceneCoordinator))
        return sceneCoordinator.present(view, animated: true)
    }
    
    func showTravelRulesInvalid(token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        let router = CertificateInvalidResultRouter(sceneCoordinator: sceneCoordinator)
        let view = CertificateInvalidResultSceneFactory(router: router,
                                                        token: token)
        return sceneCoordinator.present(view, animated: true)
    }
    
    func showTravelRulesValid(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        let router = VaccinationCycleCompleteResultRouter(sceneCoordinator: sceneCoordinator)
        let view = VaccinationCycleCompleteResultSceneFactory(router: router,
                                                              token: token)
        return sceneCoordinator.present(view, animated: true)

    }
}
