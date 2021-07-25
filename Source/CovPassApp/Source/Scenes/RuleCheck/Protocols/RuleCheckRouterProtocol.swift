//
//  RuleCheckRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation
import PromiseKit

protocol RuleCheckRouterProtocol: DialogRouterProtocol {
    func showCountrySelection(countries: [String], country: String) -> Promise<String>
    func showDateSelection(date: Date) -> Promise<Date>
    func showResultDetail(result: CertificateResult, country: String, date: Date) -> Promise<Void>
}
