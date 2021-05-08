//
//  UIView+Accessibility.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public extension UIView {
    func enableAccessibility(label: String? = nil, hint: String? = nil, traits: UIAccessibilityTraits? = nil) {
        isAccessibilityElement = true
        label.map { accessibilityLabel = $0 }
        hint.map { accessibilityHint = $0 }
        traits.map { accessibilityTraits = $0 }
    }

    func disableAccessibility() {
        isAccessibilityElement = false
    }
}
