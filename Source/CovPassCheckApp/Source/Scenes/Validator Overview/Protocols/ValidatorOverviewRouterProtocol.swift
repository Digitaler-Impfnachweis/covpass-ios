//
//  ValidatorOverviewRouterProtocol.swift
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

protocol ValidatorOverviewRouterProtocol: DialogRouterProtocol {
    func scanQRCode() -> Promise<QRCodeImportResult>
    func showCertificate(_ certificate: ExtendedCBORWebToken?,
                         _2GContext: Bool,
                         userDefaults: Persistence)
    func showError(_ certificate: ExtendedCBORWebToken?,
                   error: Error,
                   _2GContext: Bool,
                   userDefaults: Persistence) -> Promise<ExtendedCBORWebToken>
    func showAppInformation(userDefaults: Persistence)
    func showGproof(repository: VaccinationRepositoryProtocol,
                    revocationRepository: CertificateRevocationRepositoryProtocol,
                    certLogic: DCCCertLogicProtocol,
                    userDefaults: Persistence,
                    boosterAsTest: Bool)
    func showCheckSituation(userDefaults: Persistence) -> Promise<Void>
    func showDataPrivacy() -> Promise<Void>
}
