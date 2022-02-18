//
//  GProofRouterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import Scanner
import UIKit

enum GProofResult {
    case startover, retry, cancel
}

protocol GProofRouterProtocol: DialogRouterProtocol, ValidationResultRouterProtocol {
    func scanQRCode() -> Promise<ScanResult>
    func showCertificate(_ certificate: CBORWebToken?,
                         _2GContext: Bool,
                         userDefaults: Persistence,
                         buttonHidden: Bool) -> Promise<CBORWebToken>
    func showError(error: Error)
    func showDifferentPerson(firstResultCert: CBORWebToken,
                             scondResultCert: CBORWebToken) -> Promise<GProofResult>
}
