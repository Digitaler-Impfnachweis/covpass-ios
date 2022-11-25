//
//  UIImageView+Scale.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public extension UIImageView {
    func pinHeightToScaleAspectFit() {
        contentMode = .scaleAspectFit
        guard let image = image else { return }
        let ratio = image.size.height / image.size.width
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: ratio).isActive = true
    }
}
