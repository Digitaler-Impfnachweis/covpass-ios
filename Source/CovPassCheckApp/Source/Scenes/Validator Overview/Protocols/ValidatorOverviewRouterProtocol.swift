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

protocol ValidatorOverviewRouterProtocol: DialogRouterProtocol, ScanAndValidateRouterProtocol {
    func showAppInformation(userDefaults: Persistence)
    func showDataPrivacy() -> Promise<Void>
    func routeToRulesUpdate(userDefaults: Persistence) -> Promise<Void>
    func showNewRegulationsAnnouncement() -> Promise<Void>
    func routeToStateSelection() -> Promise<Void>
    func showMaskRequiredBusinessRules() -> Promise<Void>
    func showMaskRequiredBusinessRulesSecondScanAllowed(token: ExtendedCBORWebToken) -> Promise<Void>
    func showMaskRequiredTechnicalError() -> Promise<Void>
    func showMaskOptional(token: ExtendedCBORWebToken) -> Promise<Void>
    func showNoMaskRules() -> Promise<Void>
}
