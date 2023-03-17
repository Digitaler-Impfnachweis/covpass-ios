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

enum TravelRulesError: Error {
    case cancel
}

enum ValidatorDetailSceneResult: Equatable {
    case ignore
    case close
    case rescan
    case scanNext
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

        static let noTravelRules_title = "dialog_no_entry_rules_available_title".localized
        static let noTravelRules_subtitle = "dialog_no_entry_rules_available_subtitle".localized
        static let noTravelRules_continue = "dialog_no_entry_rules_available_button1".localized
        static let noTravelRules_cancel = "dialog_no_entry_rules_available_button2".localized

        static let ifsg_second_scan_alreadyScanner_title = "dialog_second_scan_title".localized
        static let ifsg_second_scan_alreadyScanner_subtitle = "dialog_second_scan_message".localized
        static let ifsg_second_scan_alreadyScanner_rescan = "dialog_second_scan_button_repeat".localized
        static let ifsg_second_scan_alreadyScanner_cancel = "dialog_second_scan_button_update".localized
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

    func showAnnouncement() -> Promise<Void> {
        sceneCoordinator.present(
            AnnouncementSceneFactory(
                router: AnnouncementRouter(
                    sceneCoordinator: sceneCoordinator
                )
            )
        )
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

    // MARK: Ifsg22a Check

    func showVaccinationCycleComplete(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        let router = VaccinationCycleCompleteResultRouter(sceneCoordinator: sceneCoordinator)
        let view = VaccinationCycleCompleteResultSceneFactory(router: router,
                                                              token: token)
        return sceneCoordinator.present(view, animated: true)
    }

    func showIfsg22aCheckDifferentPerson(tokens: [ExtendedCBORWebToken]) -> Promise<ValidatorDetailSceneResult> {
        let view = DifferentPersonSceneFactory(tokens: tokens)
        return sceneCoordinator.present(view, animated: true)
    }

    func showIfsg22aNotComplete(tokens: [ExtendedCBORWebToken]) -> Promise<ValidatorDetailSceneResult> {
        let view = SecondScanSceneFactory(tokens: tokens)
        return sceneCoordinator.present(view, animated: true)
    }

    func showIfsg22aCheckError(token: ExtendedCBORWebToken?, rescanIsHidden: Bool) -> Promise<ValidatorDetailSceneResult> {
        let router = CertificateInvalidResultRouter(sceneCoordinator: sceneCoordinator)
        let view = CertificateInvalidResultSceneFactory(router: router,
                                                        token: token,
                                                        rescanIsHidden: rescanIsHidden)
        return sceneCoordinator.present(view, animated: true)
    }

    func showIfsg22aIncompleteResult() -> Promise<ValidatorDetailSceneResult> {
        let view = VaccinationCycleIncompleteResultSceneFactory(router: VaccinationCycleIncompleteResultRouter(sceneCoordinator: sceneCoordinator))
        return sceneCoordinator.present(view, animated: true)
    }

    func showTravelRulesInvalid(token: ExtendedCBORWebToken?, rescanIsHidden: Bool) -> Promise<ValidatorDetailSceneResult> {
        let router = CertificateInvalidResultRouter(sceneCoordinator: sceneCoordinator)
        let view = CertificateInvalidResultSceneFactory(router: router,
                                                        token: token,
                                                        rescanIsHidden: rescanIsHidden)
        return sceneCoordinator.present(view, animated: true)
    }

    func showTravelRulesValid(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        let router = VaccinationCycleCompleteResultRouter(sceneCoordinator: sceneCoordinator)
        let view = VaccinationCycleCompleteResultSceneFactory(router: router,
                                                              token: token)
        return sceneCoordinator.present(view, animated: true)
    }

    func showTravelRulesNotAvailable() -> Promise<Void> {
        Promise { seal in
            showDialog(
                title: Constants.Keys.noTravelRules_title,
                message: Constants.Keys.noTravelRules_subtitle,
                actions: [
                    DialogAction(
                        title: Constants.Keys.noTravelRules_continue,
                        style: UIAlertAction.Style.default,
                        isEnabled: true,
                        completion: { _ in
                            seal.fulfill_()
                        }
                    ),
                    DialogAction(
                        title: Constants.Keys.noTravelRules_cancel,
                        style: UIAlertAction.Style.default,
                        isEnabled: true,
                        completion: { _ in
                            seal.reject(TravelRulesError.cancel)
                        }
                    )
                ],
                style: .alert
            )
        }
    }

    func sameTokenScanned() -> Promise<ValidatorDetailSceneResult> {
        Promise { seal in
            showDialog(
                title: Constants.Keys.ifsg_second_scan_alreadyScanner_title,
                message: Constants.Keys.ifsg_second_scan_alreadyScanner_subtitle,
                actions: [
                    DialogAction(
                        title: Constants.Keys.ifsg_second_scan_alreadyScanner_rescan,
                        style: UIAlertAction.Style.default,
                        isEnabled: true,
                        completion: { _ in
                            seal.fulfill(.rescan)
                        }
                    ),
                    DialogAction(
                        title: Constants.Keys.ifsg_second_scan_alreadyScanner_cancel,
                        style: UIAlertAction.Style.default,
                        isEnabled: true,
                        completion: { _ in
                            seal.fulfill(.close)
                        }
                    )
                ],
                style: .alert
            )
        }
    }
}
