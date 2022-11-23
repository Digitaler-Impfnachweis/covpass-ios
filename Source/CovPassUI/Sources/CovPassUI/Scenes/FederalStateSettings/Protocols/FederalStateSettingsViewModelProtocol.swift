//
//  FederalStateSettingsViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public protocol FederalStateSettingsViewModelProtocol {
    var title: String { get }
    var copy1Text: String { get }
    var copy2Text: String? { get }
    var inputTitle: String { get }
    var inputValue: String { get }
    var openingAnnounce: String { get }
    var closingAnnounce: String { get }
    var choosenState: String { get }

    func showFederalStateSelection() -> Promise<Void>
}
