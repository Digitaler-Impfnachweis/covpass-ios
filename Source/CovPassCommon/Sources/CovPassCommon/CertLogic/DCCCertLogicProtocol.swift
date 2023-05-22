//
//  File.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import Foundation
import PromiseKit

public protocol DCCCertLogicProtocol {
    var countries: [Country] { get }
    func rulesAvailable(logicType: DCCCertLogic.LogicType, region: String?) -> Bool
    func rules(logicType: DCCCertLogic.LogicType, country: String?, region: String?) -> [Rule]
    func validate(type: DCCCertLogic.LogicType,
                  countryCode: String,
                  region: String?,
                  validationClock: Date,
                  certificate: CBORWebToken) throws -> [ValidationResult]
}
