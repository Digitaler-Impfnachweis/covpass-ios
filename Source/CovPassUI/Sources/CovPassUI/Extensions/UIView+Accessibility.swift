//
//  UIView+Accessibility.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public extension UIView {
    func enableAccessibility(label: String? = nil, value: String? = nil, hint: String? = nil, traits: UIAccessibilityTraits? = nil) {
        isAccessibilityElement = true
        label.map { accessibilityLabel = $0 }
        value.map { accessibilityValue = $0 }
        hint.map { accessibilityHint = $0 }
        traits.map { accessibilityTraits = $0 }
    }

    func disableAccessibility() {
        isAccessibilityElement = false
    }
}
