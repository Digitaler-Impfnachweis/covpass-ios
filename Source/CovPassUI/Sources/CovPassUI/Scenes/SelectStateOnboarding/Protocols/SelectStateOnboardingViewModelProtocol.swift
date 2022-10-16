//
//  SelectStateOnboardingViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

public protocol SelectStateOnboardingViewModelProtocol {
    var title: String { get set }
    var image: UIImage { get set }
    var copyText: String { get set }
    var inputTitle: String { get set }
    var inputValue: String { get }
    var copy2Text: String { get set }
    func showFederalStateSelection() -> Promise<Void>
    func close()
}
