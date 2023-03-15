//
//  CertificatesOverviewRouter.swift
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

private enum Constants {
    enum Config {
        static let covpassCheckAppStoreURL = URL(string: "https://apps.apple.com/de/app/covpass-check/id1566140314")
    }

    enum Texts {
        static let errorTitle = "file_import_error_access_title".localized
        static let errorMessage = "file_import_error_access_copy".localized
        static let errorButtonText = "file_import_error_access_button".localized
    }

    enum Reissue {
        enum NotDe {
            static let title = "renewal_expiry_modal_not_available_title".localized
            static let copy = "renewal_expiry_modal_not_available_copy".localized
            static let buttonTitle = "renewal_expiry_modal_not_available_title_1".localized
        }
    }
}

class CertificatesOverviewRouter: CertificatesOverviewRouterProtocol, DialogRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showAnnouncement() -> Promise<Void> {
        sceneCoordinator.present(
            AnnouncementSceneFactory(
                router: AnnouncementRouter(
                    sceneCoordinator: sceneCoordinator
                )
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

    func showCertificates(certificates: [ExtendedCBORWebToken],
                          vaccinationRepository: VaccinationRepositoryProtocol,
                          boosterLogic: BoosterLogicProtocol) -> Promise<CertificateDetailSceneResult> {
        let router = CertificatesOverviewPersonRouter(sceneCoordinator: sceneCoordinator)
        let sceneFactory = CertificatesOverviewPersonSceneFactory(router: router,
                                                                  certificates: certificates,
                                                                  vaccinationRepository: vaccinationRepository,
                                                                  boosterLogic: boosterLogic)
        return sceneCoordinator.present(sceneFactory, animated: true)
    }

    func showCertificatesDetail(certificates: [ExtendedCBORWebToken]) -> Promise<CertificateDetailSceneResult> {
        sceneCoordinator.push(
            CertificateDetailSceneFactory(
                router: CertificateDetailRouter(sceneCoordinator: sceneCoordinator),
                certificates: certificates
            )
        )
    }

    func showHowToScan() -> Promise<Void> {
        sceneCoordinator.present(
            HowToScanSceneFactory(
                router: HowToScanRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }

    func showScanCountWarning() -> Promise<Bool> {
        sceneCoordinator.present(
            ScanCountWarningFactory(router: ScanCountRouter(sceneCoordinator: sceneCoordinator))
        )
    }

    func showScanCountError() -> Promise<ScanCountErrorResponse> {
        Promise { resolver in
            showDialog(title: "certificate_add_error_maximum_title".localized,
                       message: "certificate_add_error_maximum_copy".localized,
                       actions: [
                           DialogAction(title: "certificate_add_error_maximum_button_1".localized,
                                        style: UIAlertAction.Style.default,
                                        isEnabled: true,
                                        completion: { _ in
                                            resolver.fulfill(.download)
                                        }),
                           DialogAction(title: "certificate_add_error_maximum_button_2".localized,
                                        style: UIAlertAction.Style.default,
                                        isEnabled: true,
                                        completion: { _ in
                                            resolver.fulfill(.faq)
                                        }),
                           DialogAction(title: "certificate_add_error_maximum_button_3".localized,
                                        style: UIAlertAction.Style.default,
                                        isEnabled: true,
                                        completion: { _ in
                                            resolver.fulfill(.ok)
                                        })
                       ],
                       style: .alert)
        }
    }

    func toAppstoreCheckApp() {
        if let url = Constants.Config.covpassCheckAppStoreURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    func toFaqWebsite(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    func showRuleCheck() -> Promise<Void> {
        sceneCoordinator.present(
            RuleCheckSceneFactory(
                router: RuleCheckRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }

    func showQRCodeScanAndSelectionView() -> Promise<QRCodeImportResult> {
        sceneCoordinator.present(
            ScanSceneFactory(
                cameraAccessProvider: CameraAccessProvider(router: DialogRouter(sceneCoordinator: sceneCoordinator)),
                router: ScanRouter(sceneCoordinator: sceneCoordinator),
                isDocumentPickerEnabled: true
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

    func showBoosterNotification() -> Promise<Void> {
        sceneCoordinator.present(BoosterNotificationSceneFactory())
    }

    func startValidationAsAService(with data: ValidationServiceInitialisation) {
        sceneCoordinator.present(
            ValidationServiceFactory(router: ValidationServiceRouter(sceneCoordinator: sceneCoordinator),
                                     initialisationData: data))
    }

    func showExtensionRenewalReissue(for cborWebTokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        if cborWebTokens.isEmpty {
            return .value
        }
        return sceneCoordinator.present(
            ReissueStartSceneFactory(
                router: ReissueStartRouter(sceneCoordinator: sceneCoordinator),
                tokens: cborWebTokens,
                context: .certificateExtension
            )
        )
    }

    func showBoosterRenewalReissue(for cborWebTokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        if cborWebTokens.isEmpty {
            return .value
        }
        return sceneCoordinator.present(
            ReissueStartSceneFactory(
                router: ReissueStartRouter(sceneCoordinator: sceneCoordinator),
                tokens: cborWebTokens,
                context: .boosterRenewal
            )
        )
    }

    func showCertificatePicker(tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        sceneCoordinator.present(
            CertificateImportSelectionFactory(
                importTokens: tokens,
                router: CertificateImportSelectionRouter(
                    sceneCoordinator: sceneCoordinator
                )
            )
        )
    }

    func showCertificateImportError() {
        showDialog(
            title: Constants.Texts.errorTitle,
            message: Constants.Texts.errorMessage,
            actions: [.init(title: Constants.Texts.errorButtonText)],
            style: .alert
        )
    }

    func showCertificateExpiredNotDe() {
        showDialog(
            title: Constants.Reissue.NotDe.title,
            message: Constants.Reissue.NotDe.copy,
            actions: [.init(title: Constants.Reissue.NotDe.buttonTitle)],
            style: .alert
        )
    }
}
