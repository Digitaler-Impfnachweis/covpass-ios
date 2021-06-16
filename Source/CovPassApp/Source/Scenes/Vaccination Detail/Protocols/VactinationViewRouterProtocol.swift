//
//  VactinationViewRouterProtocol.swift
//  CovPassApp
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import UIKit

protocol VactinationViewRouterProtocol {
    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void>
}
