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
                         userDefaults: Persistence)
    func showError(_ certificate: ExtendedCBORWebToken?,
                   error: Error,
                   userDefaults: Persistence) -> Promise<ExtendedCBORWebToken>
    func showAppInformation(userDefaults: Persistence)
    func showDataPrivacy() -> Promise<Void>
    func routeToRulesUpdate(userDefaults: Persistence) -> Promise<Void>
    func showNewRegulationsAnnouncement() -> Promise<Void>
}
