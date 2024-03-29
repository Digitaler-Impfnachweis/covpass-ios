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
    var isVaccinationCycleIsComplete: HolderStatusResponse = .init(passed: true, results: nil)
    var areIfsgRulesAvailable = true
    var areTravelRulesAvailableForGermanyResponse = true
    var validCertificates: [ExtendedCBORWebToken]?
    var checkDomesticAcceptanceAndInvalidationRulesResult = CertificateHolderStatusResult.passed
    var checkDomesticInvalidationRulesResult = CertificateHolderStatusResult.passed
    var checkEuInvalidationRulesResult = CertificateHolderStatusResult.passed

    func areTravelRulesAvailableForGermany() -> Bool {
        areTravelRulesAvailableForGermanyResponse
    }

    func checkDomesticAcceptanceAndInvalidationRules(_: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        checkDomesticAcceptanceAndInvalidationRulesResult
    }

    func checkDomesticInvalidationRules(_: [CovPassCommon.ExtendedCBORWebToken]) -> CovPassCommon.CertificateHolderStatusResult {
        checkDomesticInvalidationRulesResult
    }

    func checkEuInvalidationRules(_: [ExtendedCBORWebToken]) -> CertificateHolderStatusResult {
        checkEuInvalidationRulesResult
    }

    func validCertificates(_ certificates: [ExtendedCBORWebToken], logicType _: DCCCertLogic.LogicType) -> [ExtendedCBORWebToken] {
        validCertificates ?? certificates
    }

    func vaccinationCycleIsComplete(_: [ExtendedCBORWebToken]) -> HolderStatusResponse {
        isVaccinationCycleIsComplete
    }

    func ifsg22aRulesAvailable() -> Bool {
        areIfsgRulesAvailable
    }
}
