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
    let showCheckSituationExpectation = XCTestExpectation(description: "showCheckSituationExpectation")
    let showDialogExpectation = XCTestExpectation(description: "showDialogExpectation")
    let showCertificatesReissueExpectation = XCTestExpectation(description: "showCertificatesReissueExpectation")
    let toWebsiteFAQExpectation = XCTestExpectation(description: "toWebsiteFAQExpectation")
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    var error: Error?
    var scanCountErrorResponse: ScanCountErrorResponse = .download
    var receivedFaqURL: URL?

    func showCheckSituation(userDefaults: Persistence) -> Promise<Void> {
        showCheckSituationExpectation.fulfill()
        return .value
    }

    func showDataPrivacy() -> Promise<Void> {
        .value
    }

    func showAnnouncement() -> Promise<Void> {
        .value
    }

    func showCertificates(_ certificates: [ExtendedCBORWebToken]) -> Promise<CertificateDetailSceneResult> {
        .value(.addNewCertificate)
    }

    func showHowToScan() -> Promise<Void> {
        .value
    }

    func showScanCountWarning() -> Promise<Bool> {
        .value(true)
    }

    func showScanCountError() -> Promise<ScanCountErrorResponse> {
        .value(scanCountErrorResponse)
    }

    func showRuleCheck() -> Promise<Void> {
        .value
    }

    func scanQRCode() -> Promise<ScanResult> {
        if let error = error {
            return .init(error: error)
        }
        return .value(.success(""))
    }

    func showAppInformation() {

    }

    func showBoosterNotification() -> Promise<Void> {
        .value
    }

    func showScanPleaseHint() -> Promise<Void> {
        .value
    }

    func showDialog(title: String?, message: String?, actions: [DialogAction], style: UIAlertController.Style) {
        showDialogExpectation.fulfill()
    }

    func toAppstoreCheckApp() {}
    func toFaqWebsite(_ url: URL) {
        receivedFaqURL = url
        toWebsiteFAQExpectation.fulfill()
    }
    func startValidationAsAService(with data: ValidationServiceInitialisation) {}
    func showCertificatesReissue(for cborWebTokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        showCertificatesReissueExpectation.fulfill()
        return .value
    }
}
