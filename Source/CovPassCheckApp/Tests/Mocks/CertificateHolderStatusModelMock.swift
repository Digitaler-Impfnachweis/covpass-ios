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

    var areMaskRulesAvailable = false
    var needsMask = false
    var fullyImmunized = false
    var domesticRulesPassedResult = CertificateHolderStatusResult.passed
    var euInvalidationRulesPassedResult = CertificateHolderStatusResult.passed

    func checkDomesticAcceptanceRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        domesticRulesPassedResult
    }
    
    func euInvalidationRulesPassed(_ certificates: [ExtendedCBORWebToken], countryCode: String) -> CertificateHolderStatusResult {
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
        return areMaskRulesAvailable
    }
}
