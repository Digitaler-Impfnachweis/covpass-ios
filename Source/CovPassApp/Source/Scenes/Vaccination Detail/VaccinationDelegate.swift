//
//  VaccinationDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

protocol VaccinationDelegate: AnyObject {
    func didPressDelete(_ vaccination: Vaccination) -> Promise<Void>
    func didUpdateCertificates(_ certificates: [ExtendedCBORWebToken])
    func updateDidFailWithError(_ error: Error)
}
