//
//  SelectStateOnboardingViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

public protocol SelectStateOnboardingViewModelProtocol {
    var title: String { get }
    var image: UIImage { get }
    var copyText: String { get }
    var inputTitle: String { get }
    var inputValue: String { get }
    var copy2Text: String { get }
    var copy3Text: String? { get }
    var openingAnnounce: String { get }
    var closingAnnounce: String { get }
    var choosenState: String { get }
    func showFederalStateSelection() -> Promise<Void>
    func showFAQ()
    func close()
}
