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
    var domesticRulesPassedResult = CertificateHolderStatusResult.failedFunctional
    var euInvalidationRulesPassedResult = CertificateHolderStatusResult.failedFunctional

    func checkDomesticAcceptanceAndInvalidationRules(_ certificates: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        domesticRulesPassedResult
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
        return areMaskRulesAvailable
    }
}
