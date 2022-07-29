//
//  ValidatorOverviewRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import Scanner
import UIKit
import CovPassUI

protocol TrustedListDetailsRouterProtocol: DialogRouterProtocol {
    func showError(error: Error)
}
