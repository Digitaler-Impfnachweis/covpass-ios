//
//  CertificateHolderStatusModelMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

struct CertificateHolderStatusModelMock: CertificateHolderStatusModelProtocol {
    var areMaskRulesAvailable = false
    var needsMask = false
    var fullyImmunized = false
    var isVaccinationCycleComplete = true
    var areIfsg22aRulesAvailable = true
    var checkDomesticAcceptanceAndInvalidationRulesResult = CertificateHolderStatusResult.passed
    var checkDomesticInvalidationRulesResult = CertificateHolderStatusResult.passed
    var checkEuInvalidationRulesResult = CertificateHolderStatusResult.passed
    var validCertificates: [ExtendedCBORWebToken]?
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
