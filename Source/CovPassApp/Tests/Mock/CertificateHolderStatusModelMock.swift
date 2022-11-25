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
    var needsMask = false
    var holderIsFullyImmunized = false
    var areMaskRulesAvailable = false
    var isVaccinationCycleIsComplete = true
    var areIfsgRulesAvailable = true
    var validCertificates: [ExtendedCBORWebToken]?
    var checkDomesticAcceptanceAndInvalidationRulesResult = CertificateHolderStatusResult.passed
    var checkDomesticInvalidationRulesResult = CertificateHolderStatusResult.passed
    var checkEuInvalidationRulesResult = CertificateHolderStatusResult.passed
    var latestMaskRuleDate: Date?

    func checkDomesticAcceptanceAndInvalidationRules(_: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        checkDomesticAcceptanceAndInvalidationRulesResult
    }

    func checkDomesticInvalidationRules(_: [CovPassCommon.ExtendedCBORWebToken]) -> CovPassCommon.CertificateHolderStatusResult {
        checkDomesticInvalidationRulesResult
    }

    func checkEuInvalidationRules(_: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        checkEuInvalidationRulesResult
    }

    func holderIsFullyImmunized(_: [ExtendedCBORWebToken]) -> Bool {
        holderIsFullyImmunized
    }

    func holderNeedsMask(_: [ExtendedCBORWebToken], region _: String?) -> Bool {
        needsMask
    }

    func holderNeedsMaskAsync(_: [ExtendedCBORWebToken], region _: String?) -> Guarantee<Bool> {
        .value(needsMask)
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
        isVaccinationCycleIsComplete
    }

    func ifsg22aRulesAvailable() -> Bool {
        areIfsgRulesAvailable
    }
}
