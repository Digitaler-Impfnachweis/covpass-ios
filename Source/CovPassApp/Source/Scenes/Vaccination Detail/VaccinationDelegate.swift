//
//  VaccinationDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import PromiseKit

protocol VaccinationDelegate: AnyObject {
    func didConfirmDeletion() -> Promise<Void>
    func didUpdateCertificates(_ certificates: [ExtendedCBORWebToken])
    func updateDidFailWithError(_ error: Error)
}
