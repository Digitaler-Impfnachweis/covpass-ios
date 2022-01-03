//
//  CertificatesOverviewRouterProtocol.swift
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

/// Used to response with decision of the user in a dialog in case of QRCodeError.errorCountOfCertificatesReached
enum ScanCountErrorResponse {
    case download, faq, ok
}

protocol CertificatesOverviewRouterProtocol: DialogRouterProtocol {
    func showAnnouncement() -> Promise<Void>
    func showCertificates(_ certificates: [ExtendedCBORWebToken]) -> Promise<CertificateDetailSceneResult>
    func showHowToScan() -> Promise<Void>
    func showScanCountWarning() -> Promise<Bool>
    func showScanCountError() -> Promise<ScanCountErrorResponse>
    func showRuleCheck() -> Promise<Void>
    func scanQRCode() -> Promise<ScanResult>
    func showAppInformation()
    func showBoosterNotification() -> Promise<Void>
    func showScanPleaseHint() -> Promise<Void>
    func toAppstoreCheckApp()
    func toFaqWebsite()
    func startValidationAsAService(with data: ValidationServiceInitialisation)
}
