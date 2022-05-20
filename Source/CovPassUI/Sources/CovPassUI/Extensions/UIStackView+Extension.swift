//
//  UIStackView+Extension.swift
//  
//
//  Created by Thomas Kuleßa on 18.05.22.
//

import UIKit

public extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach(removeArrangedSubview)
    }
}

