//
//  UIImageView+Scale.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public extension UIImageView {
    func pinHeightToScaleAspectFit() {
        contentMode = .scaleAspectFit
        guard let image = self.image else { return }
        let ratio = image.size.height / image.size.width
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: ratio).isActive = true
    }
}
