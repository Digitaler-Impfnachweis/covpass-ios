//
//  CornerRadius.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public protocol CornerRadius {
    /// Use this method in order to round specific corners
    ///
    /// - Parameters:
    ///   - corners: The corners that should be updated with that radius
    ///   - radius: The value of the cornerRadius
    func round(for corners: CACornerMask, with radius: CGFloat)

    /// Use this method to restore default corners for a view that was
    /// previously rounded with the methods above
    func roundRemove()
}
