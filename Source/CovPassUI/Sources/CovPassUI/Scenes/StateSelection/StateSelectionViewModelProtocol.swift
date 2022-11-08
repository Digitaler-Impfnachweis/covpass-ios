//
//  StateSelectionViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

public protocol StateSelectionViewModelProtocol {
    var pageTitle: String { get }
    var states: [Country] { get }
    var openingAnnounce: String { get }
    var closingAnnounce: String { get }
    var choosenState: String { get }
    func choose(state: String)
    func close()
}
