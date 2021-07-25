//
//  DCCServiceMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import CovPassCommon
import Foundation
import PromiseKit

public struct DCCServiceMock: DCCServiceProtocol {
    public init() {}

    public func loadDCCRules() -> Promise<[RuleSimple]> {
        return Promise.value([])
    }

    public func loadDCCRule(country _: String, hash _: String) -> Promise<Rule> {
        return Promise(error: ApplicationError.unknownError)
    }
}
