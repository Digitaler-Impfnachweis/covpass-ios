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

protocol ValidatorOverviewRouterProtocol: DialogRouterProtocol, ScanQRCodeProtocol, MaskCheckRouterProtocol, CheckImmunityRouterProtocol {
    func showAppInformation(userDefaults: Persistence)
    func showDataPrivacy() -> Promise<Void>
    func showNewRegulationsAnnouncement() -> Promise<Void>
    func routeToStateSelection() -> Promise<Void>
    func routeToRulesUpdate(userDefaults: Persistence) -> Promise<Void>
    func routeToChooseCheckSituation() -> Promise<Void>
}

protocol MaskCheckRouterProtocol {
    // MARK: Mask Check

    func showMaskRequiredBusinessRules(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult>
    func showMaskRequiredBusinessRulesSecondScanAllowed(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult>
    func showMaskRequiredTechnicalError(token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult>
    func showMaskOptional(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult>
    func showNoMaskRules(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult>
    func showMaskCheckDifferentPerson(token1OfPerson: ExtendedCBORWebToken, token2OfPerson: ExtendedCBORWebToken) -> Promise<DifferentPersonResult>
    func showMaskCheckSameCertType()
}

protocol CheckImmunityRouterProtocol {
    // MARK: Ifsg22a Check

    func showVaccinationCycleComplete(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult>
    func showIfsg22aCheckDifferentPerson(token1OfPerson: ExtendedCBORWebToken, token2OfPerson: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult>
    func showIfsg22aNotComplete(token: ExtendedCBORWebToken, secondToken: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult>
    func showIfsg22aIncompleteResult(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult>
    func showIfsg22aCheckError(token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult>
    func showTravelRulesValid(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult>
    func showTravelRulesInvalid(token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult>
}
