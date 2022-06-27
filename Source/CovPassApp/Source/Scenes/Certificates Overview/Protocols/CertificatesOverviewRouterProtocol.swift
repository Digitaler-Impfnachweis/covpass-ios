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
    func showCertificates(certificates: [ExtendedCBORWebToken],
                          vaccinationRepository: VaccinationRepositoryProtocol,
                          boosterLogic: BoosterLogicProtocol) -> Promise<CertificateDetailSceneResult>
    func showCertificatesDetail(certificates: [ExtendedCBORWebToken]) -> Promise<CertificateDetailSceneResult>
    func showHowToScan() -> Promise<Void>
    func showScanCountWarning() -> Promise<Bool>
    func showScanCountError() -> Promise<ScanCountErrorResponse>
    func showRuleCheck() -> Promise<Void>
    func scanQRCode() -> Promise<ScanResult>
    func showAppInformation()
    func showBoosterNotification() -> Promise<Void>
    func showScanPleaseHint() -> Promise<Void>
    func showDataPrivacy() -> Promise<Void>
    func toAppstoreCheckApp()
    func toFaqWebsite(_ url: URL)
    func startValidationAsAService(with data: ValidationServiceInitialisation)
    func showCheckSituation(userDefaults: Persistence) -> Promise<Void>
    func showCertificatesReissue(for cborWebTokens: [ExtendedCBORWebToken],
                                 context: ReissueContext) -> Promise<Void>
    func showCertificatePicker(tokens: [ExtendedCBORWebToken]) -> Promise<Void>
    func showCertificateImportError()
}
