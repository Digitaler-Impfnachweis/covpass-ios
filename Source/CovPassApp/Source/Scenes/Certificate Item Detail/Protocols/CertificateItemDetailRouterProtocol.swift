//
//  CertificateItemDetailRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

protocol CertificateItemDetailRouterProtocol: DialogRouterProtocol {
    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void>
}
