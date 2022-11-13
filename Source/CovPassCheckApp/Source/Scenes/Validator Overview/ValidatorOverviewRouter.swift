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
    
    // MARK: Ifsg22a Check

    func showVaccinationCycleComplete(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        let router = VaccinationCycleCompleteResultRouter(sceneCoordinator: sceneCoordinator)
        let view = VaccinationCycleCompleteResultSceneFactory(router: router,
                                                              token: token)
        return sceneCoordinator.present(view, animated: true)
    }
    
    func showNoIfsg22aCheckRulesNotAvailable(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
#warning("TODO: finalize in upcoming sotries")
        print("showNoIfsg22aCheckRulesNotAvailable")
        return .value(.close)
    }
    
    func showIfsg22aCheckDifferentPerson(token1OfPerson: ExtendedCBORWebToken, token2OfPerson: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        print("showIfsg22aCheckDifferentPerson")
#warning("TODO: finalize in upcoming sotries")
        return .value(.close)
    }
    
    func showIfsg22aCheckSameCert() {
        print("showIfsg22aCheckSameCert")
#warning("TODO: finalize in upcoming sotries")
    }
    
    func showIfsg22aNotComplete(token: ExtendedCBORWebToken, isThirdScan: Bool) -> Promise<ValidatorDetailSceneResult> {
        let view = SecondScanSceneFactory(isThirdScan: isThirdScan,
                                          token: token)
        return sceneCoordinator.present(view, animated: true)
    }
    
    func showIfsg22aCheckError(token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        let router = CertificateInvalidResultRouter(sceneCoordinator: sceneCoordinator)
        let view = CertificateInvalidResultSceneFactory(router: router,
                                                              token: token)
        return sceneCoordinator.present(view, animated: true)
    }
    
    func showIfsg22aCheckTestIsNotAllowed(token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
#warning("TODO: finalize in upcoming sotries")
        return .value(.close)
    }
    
    func showIfsg22aIncompleteResult(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        let view = VaccinationCycleIncompleteResultSceneFactory(router: VaccinationCycleIncompleteResultRouter(sceneCoordinator: sceneCoordinator))
        return sceneCoordinator.present(view, animated: true)
    }
}
