//
//  ScanCountRouterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation

protocol ScanCountRouterProtocol: DialogRouterProtocol {
    func routeToSafari(url: URL)
}
