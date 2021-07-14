//
//  DCCServiceMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import CertLogic
import CovPassCommon

public struct DCCServiceMock: DCCServiceProtocol {
    public init() {}

    public func loadDCCRules() -> Promise<[RuleSimple]> {
        return Promise.value([])
    }

    public func loadDCCRule(country: String, hash: String) -> Promise<RuleExtension> {
        return Promise(error: ApplicationError.unknownError)
    }
}
