//
//  CertificateHolderStatusModelMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

class CertificateHolderStatusModelMock: CertificateHolderStatusModelProtocol {
    var areMaskRulesAvailable = true
    var needsMask = true
    var fullyImmunized = true
    var isVaccinationCycleComplete = true
    var areIfsg22aRulesAvailable = true
    var areTravelRulesAvailableForGermanyResponse = true
    var domesticAcceptanceAndInvalidationRulesPassedResult = CertificateHolderStatusResult.failedFunctional
    var domesticInvalidationRulesPassedResult = CertificateHolderStatusResult.failedFunctional
    var euInvalidationRulesPassedResult = CertificateHolderStatusResult.failedFunctional
    var validCertificates: [ExtendedCBORWebToken]?
    var latestMaskRuleDate: Date?

    func areTravelRulesAvailableForGermany() -> Bool {
        areTravelRulesAvailableForGermanyResponse
    }

    func checkDomesticAcceptanceAndInvalidationRules(_: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        domesticAcceptanceAndInvalidationRulesPassedResult
    }

    func checkDomesticInvalidationRules(_: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        domesticInvalidationRulesPassedResult
    }

    func checkEuInvalidationRules(_: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        euInvalidationRulesPassedResult
    }

    func holderNeedsMask(_: [ExtendedCBORWebToken], region _: String?) -> Bool {
        needsMask
    }

    func holderNeedsMaskAsync(_: [ExtendedCBORWebToken], region _: String?) -> Guarantee<Bool> {
        .value(needsMask)
    }

    func holderIsFullyImmunized(_: [ExtendedCBORWebToken]) -> Bool {
        fullyImmunized
    }

    func maskRulesAvailable(for _: String?) -> Bool {
        areMaskRulesAvailable
    }

    func latestMaskRuleDate(for _: String?) -> Date? {
        latestMaskRuleDate
    }

    func validCertificates(_ certificates: [ExtendedCBORWebToken], logicType _: DCCCertLogic.LogicType) -> [ExtendedCBORWebToken] {
        validCertificates ?? certificates
    }

    func vaccinationCycleIsComplete(_: [CovPassCommon.ExtendedCBORWebToken]) -> Bool {
        isVaccinationCycleComplete
    }

    func ifsg22aRulesAvailable() -> Bool {
        areIfsg22aRulesAvailable
    }
}
