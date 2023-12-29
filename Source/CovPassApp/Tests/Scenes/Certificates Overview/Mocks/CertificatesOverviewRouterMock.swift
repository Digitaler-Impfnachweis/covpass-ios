//
//  CertificatesOverviewRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class CertificatesOverviewRouterMock: CertificatesOverviewRouterProtocol {
    let showStateSelectionOnboardingExpectation = XCTestExpectation(description: "showStateSelectionOnboardingExpectation")
    let showCheckSituationExpectation = XCTestExpectation(description: "showCheckSituationExpectation")
    let showDialogExpectation = XCTestExpectation(description: "showDialogExpectation")
    let showBoosterRenewalReissueExpectation = XCTestExpectation(description: "showBoosterRenewalReissueExpectation")
    let showExtensionRenewalReissueExpectation = XCTestExpectation(description: "showExtensionRenewalReissueExpectation")
    let showCertificateExpectation = XCTestExpectation(description: "showCertificateExpectation")
    let showCertificateModalExpectation = XCTestExpectation(description: "showCertificateExpectation")
    let toWebsiteFAQExpectation = XCTestExpectation(description: "toWebsiteFAQExpectation")
    let showCertificateImportErrorExpectation = XCTestExpectation(description: "showCertificateImportErrorExpectation")
    let showCertificatePickerExpectation = XCTestExpectation(description: "showCertificatePickerExpectation")
    let showQRCodeScanAndSelectionViewExpectation = XCTestExpectation(description: "showQRCodeScanAndSelectionViewExpectation")
    let showHowToScanExpectation = XCTestExpectation(description: "showHowToScanExpectation")
    let showCertificateExpiredNotDeExpectation = XCTestExpectation(description: "showCertificateExpiredNotDeExpectation")
    let showAnnouncementExpectation = XCTestExpectation(description: "showAnnouncementExpectation")
    let showNewRegulationsAnnouncementExpectation = XCTestExpectation(description: "showNewRegulationsAnnouncementExpectation")
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    var error: Error?
    var scanCountErrorResponse: ScanCountErrorResponse = .download
    var receivedFaqURL: URL?
    var scanQRCodePayload: String = ""
    var receivedCertificatePickerTokens: [ExtendedCBORWebToken]?
    var showQRCodeScanAndSelectionViewValue = QRCodeImportResult.scanResult(.success(""))

    func showSundownInfo() -> PromiseKit.Promise<Void> {
        .value
    }

    func showCertificateExpiredNotDe() {
        showCertificateExpiredNotDeExpectation.fulfill()
    }

    func showCheckSituation(userDefaults _: Persistence) -> Promise<Void> {
        showCheckSituationExpectation.fulfill()
        return .value
    }

    func showDataPrivacy() -> Promise<Void> {
        .value
    }

    func showAnnouncement() -> Promise<Void> {
        showAnnouncementExpectation.fulfill()
        return .value
    }

    func showNewRegulationsAnnouncement() -> Promise<Void> {
        showNewRegulationsAnnouncementExpectation.fulfill()
        return .value
    }

    func showCertificates(certificates: [ExtendedCBORWebToken],
                          vaccinationRepository _: VaccinationRepositoryProtocol,
                          boosterLogic _: BoosterLogicProtocol) -> Promise<CertificateDetailSceneResult> {
        showCertificateModalExpectation.fulfill()
        return .value(.showCertificatesOnOverview(certificates.first!))
    }

    func showCertificatesDetail(certificates: [ExtendedCBORWebToken]) -> Promise<CertificateDetailSceneResult> {
        showCertificateExpectation.fulfill()
        return .value(.showCertificatesOnOverview(certificates.first!))
    }

    func showHowToScan() -> Promise<Void> {
        showHowToScanExpectation.fulfill()
        return .value
    }

    func showScanCountWarning() -> Promise<Bool> {
        .value(true)
    }

    func showScanCountError() -> Promise<ScanCountErrorResponse> {
        .value(scanCountErrorResponse)
    }

    func showQRCodeScanAndSelectionView() -> Promise<QRCodeImportResult> {
        showQRCodeScanAndSelectionViewExpectation.fulfill()
        if let error = error {
            return .init(error: error)
        }
        return .value(showQRCodeScanAndSelectionViewValue)
    }

    func showAppInformation() {}

    func showBoosterNotification() -> Promise<Void> {
        .value
    }

    func showScanPleaseHint() -> Promise<Void> {
        .value
    }

    func showDialog(title _: String?, message _: String?, actions _: [DialogAction], style _: UIAlertController.Style) {
        showDialogExpectation.fulfill()
    }

    func toAppstoreCheckApp() {}
    func toFaqWebsite(_ url: URL) {
        receivedFaqURL = url
        toWebsiteFAQExpectation.fulfill()
    }

    func startValidationAsAService(with _: ValidationServiceInitialisation) {}

    func showExtensionRenewalReissue(for _: [ExtendedCBORWebToken]) -> Promise<Void> {
        showExtensionRenewalReissueExpectation.fulfill()
        return .value
    }

    func showBoosterRenewalReissue(for _: [ExtendedCBORWebToken]) -> Promise<Void> {
        showBoosterRenewalReissueExpectation.fulfill()
        return .value
    }

    func showCertificatePicker(tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        receivedCertificatePickerTokens = tokens
        showCertificatePickerExpectation.fulfill()
        if let error = error {
            return .init(error: error)
        }
        return .value
    }

    func showCertificateImportError() {
        showCertificateImportErrorExpectation.fulfill()
    }

    func showStateSelectionOnboarding() -> PromiseKit.Promise<Void> {
        showStateSelectionOnboardingExpectation.fulfill()
        return .value
    }
}
