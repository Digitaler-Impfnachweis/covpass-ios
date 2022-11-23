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
    var validCertificates: [ExtendedCBORWebToken]? = nil
    var latestMaskRuleDate: Date? = nil

    func checkDomesticAcceptanceAndInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        checkDomesticAcceptanceAndInvalidationRulesResult
    }
    
    func checkDomesticInvalidationRules(_ certificates: [CovPassCommon.ExtendedCBORWebToken]) -> CovPassCommon.CertificateHolderStatusResult {
        checkDomesticInvalidationRulesResult
    }
    
    func checkEuInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        checkEuInvalidationRulesResult
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
