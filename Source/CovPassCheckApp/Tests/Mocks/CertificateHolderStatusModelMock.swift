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
    var domesticAcceptanceAndInvalidationRulesPassedResult = CertificateHolderStatusResult.failedFunctional
    var domesticInvalidationRulesPassedResult = CertificateHolderStatusResult.failedFunctional
    var euInvalidationRulesPassedResult = CertificateHolderStatusResult.failedFunctional
    var validCertificates: [ExtendedCBORWebToken]? = nil
    var latestMaskRuleDate: Date? = nil

    func checkDomesticAcceptanceAndInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        domesticAcceptanceAndInvalidationRulesPassedResult
    }
    
    func checkDomesticInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        domesticInvalidationRulesPassedResult
    }
    
    func checkEuInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        euInvalidationRulesPassedResult
    }

    func holderNeedsMask(_ certificates: [ExtendedCBORWebToken], region: String?) -> Bool {
        needsMask
    }
    func holderNeedsMaskAsync(_ certificates: [ExtendedCBORWebToken], region: String?) -> Guarantee<Bool> {
        .value(needsMask)
    }

    func holderIsFullyImmunized(_ certificates: [ExtendedCBORWebToken]) -> Bool {
        fullyImmunized
    }

    func maskRulesAvailable(for region: String?) -> Bool {
        areMaskRulesAvailable
    }

    func latestMaskRuleDate(for region: String?) -> Date? {
        latestMaskRuleDate
    }

    func validCertificates(_ certificates: [ExtendedCBORWebToken], logicType: DCCCertLogic.LogicType) -> [ExtendedCBORWebToken] {
        validCertificates ?? certificates
    }
    
    func vaccinationCycleIsComplete(_ certificates: [CovPassCommon.ExtendedCBORWebToken]) -> Bool {
        isVaccinationCycleComplete
    }
    
    func ifsg22aRulesAvailable() -> Bool {
        areIfsg22aRulesAvailable
    }
}
