//
//  HUIFocusBorderView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class HUIFocusBorderView: UIView {
    private let borderWidth: CGFloat = 2
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(frame: CGRect, cornerRadius: CGFloat = 0) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.borderColor = UIColor.brandBase.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        let inlineView = UIView(frame: .init(x: borderWidth,
                                             y: borderWidth,
                                             width: frame.size.width - 2 * borderWidth,
                                             height: frame.size.height - 2 * borderWidth))
        inlineView.layer.borderColor = UIColor.onBrandBase.cgColor
        inlineView.layer.borderWidth = borderWidth
        inlineView.layer.cornerRadius = cornerRadius - borderWidth
        inlineView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(inlineView)
    }
}
