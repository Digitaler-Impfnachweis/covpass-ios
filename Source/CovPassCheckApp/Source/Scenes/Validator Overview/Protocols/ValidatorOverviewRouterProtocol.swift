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
    func scanQRCode() -> Promise<ScanResult>
    func showCertificate(_ certificate: CBORWebToken?,
                         _2GContext: Bool,
                         userDefaults: Persistence)
    func showError(error: Error,
                   _2GContext: Bool,
                   userDefaults: Persistence) -> Promise<CBORWebToken>
    func showAppInformation(userDefaults: Persistence)
    func showGproof(initialToken: CBORWebToken,
                    repository: VaccinationRepositoryProtocol,
                    certLogic: DCCCertLogicProtocol,
                    userDefaults: Persistence,
                    boosterAsTest: Bool)
    func showCheckSituation(userDefaults: Persistence) -> Promise<Void>
}
