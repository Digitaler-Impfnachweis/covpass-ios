//
//  DCCCertLogicMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import Foundation
import PromiseKit
import XCTest

class DCCCertLogicMock: DCCCertLogicProtocol {
    var rulesAreAvailable: Bool = true

    var throwErrorOnUpdateRules: Bool = false

    var rules: [Rule] = []

    var countries: [Country] {
        [Country("DE")]
    }

    func rulesAvailable(logicType _: DCCCertLogic.LogicType, region _: String?) -> Bool {
        rulesAreAvailable
    }

    func rules(logicType _: DCCCertLogic.LogicType, country _: String?, region _: String?) -> [Rule] {
        rules
    }

    var validationError: Error?
    var validateResult: [ValidationResult]?
    func validate(type _: DCCCertLogic.LogicType, countryCode _: String, region _: String?, validationClock _: Date, certificate _: CBORWebToken) throws -> [ValidationResult] {
        if let err = validationError {
            throw err
        }
        return validateResult ?? []
    }
}
