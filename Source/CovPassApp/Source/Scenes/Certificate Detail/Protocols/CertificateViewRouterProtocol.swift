//
//  CertificateViewRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import UIKit

protocol CertificateViewRouterProtocol {
    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void>
}
