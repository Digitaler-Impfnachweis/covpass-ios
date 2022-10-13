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
    var title: String { get set }
    var copyText: String { get set }
    var inputTitle: String { get set }
    var inputValue: String { get }

    func showFederalStateSelection() -> Promise<Void>
}
