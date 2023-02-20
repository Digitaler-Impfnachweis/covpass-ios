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
    var isVaccinationCycleComplete: HolderStatusResponse = .init(passed: true, results: nil)
    var areIfsg22aRulesAvailable = true
    var areTravelRulesAvailableForGermanyResponse = true
    var domesticAcceptanceAndInvalidationRulesPassedResult = CertificateHolderStatusResult.failedFunctional
    var domesticInvalidationRulesPassedResult = CertificateHolderStatusResult.failedFunctional
    var euInvalidationRulesPassedResult = CertificateHolderStatusResult.failedFunctional
    var validCertificates: [ExtendedCBORWebToken]?

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

    func validCertificates(_ certificates: [ExtendedCBORWebToken], logicType _: DCCCertLogic.LogicType) -> [ExtendedCBORWebToken] {
        validCertificates ?? certificates
    }

    func vaccinationCycleIsComplete(_: [ExtendedCBORWebToken]) -> HolderStatusResponse {
        isVaccinationCycleComplete
    }

    func ifsg22aRulesAvailable() -> Bool {
        areIfsg22aRulesAvailable
    }
}
