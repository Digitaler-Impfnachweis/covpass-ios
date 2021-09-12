//
//  DCCCertLogicMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import PromiseKit
import CertLogic

class DCCCertLogicMock: DCCCertLogicProtocol {
    var countries: [String] {
        ["DE"]
    }

    func lastUpdatedDCCRules() -> Date? {
        nil
    }

    var validationError: Error?
    var validateResult: [ValidationResult]?
    func validate(type: DCCCertLogic.LogicType, countryCode: String, validationClock: Date, certificate: CBORWebToken) throws -> [ValidationResult] {
        if let err = validationError {
            throw err
        }
        return validateResult ?? []
    }

    func updateRulesIfNeeded() -> Promise<Void> {
        Promise.value
    }

    func updateRules() -> Promise<Void> {
        Promise.value
    }
}
