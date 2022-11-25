//
//  UIStackView+Extension.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public extension UIStackView {
    func removeAllArrangedSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
        arrangedSubviews.forEach(removeArrangedSubview)
    }
}
