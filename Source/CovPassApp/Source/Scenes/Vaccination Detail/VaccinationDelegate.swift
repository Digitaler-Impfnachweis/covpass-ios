//
//  VaccinationDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

protocol VaccinationDelegate: AnyObject {
    func showDeleteDialog() -> Promise<Void>
    func didDeleteCertificate()
    func updateDidFailWithError(_ error: Error)
}
