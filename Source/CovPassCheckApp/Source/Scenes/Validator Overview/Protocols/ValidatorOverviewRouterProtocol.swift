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

protocol ValidatorOverviewRouterProtocol: DialogRouterProtocol, ScanQRCodeProtocol, CheckImmunityRouterProtocol {
    func showAppInformation(userDefaults: Persistence)
    func showDataPrivacy() -> Promise<Void>
    func showAnnouncement() -> Promise<Void>
    func routeToStateSelection() -> Promise<Void>
    func routeToRulesUpdate(userDefaults: Persistence) -> Promise<Void>
    func routeToChooseCheckSituation() -> Promise<Void>
    func sameTokenScanned() -> Promise<ValidatorDetailSceneResult>
}

protocol CheckImmunityRouterProtocol {
    func showVaccinationCycleComplete(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult>
    func showIfsg22aCheckDifferentPerson(tokens: [ExtendedCBORWebToken]) -> Promise<ValidatorDetailSceneResult>
    func showIfsg22aNotComplete(tokens: [ExtendedCBORWebToken]) -> Promise<ValidatorDetailSceneResult>
    func showIfsg22aIncompleteResult() -> Promise<ValidatorDetailSceneResult>
    func showIfsg22aCheckError(token: ExtendedCBORWebToken?, rescanIsHidden: Bool) -> Promise<ValidatorDetailSceneResult>
    func showTravelRulesValid(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult>
    func showTravelRulesInvalid(token: ExtendedCBORWebToken?, rescanIsHidden: Bool) -> Promise<ValidatorDetailSceneResult>
    func showTravelRulesNotAvailable() -> Promise<Void>
}
