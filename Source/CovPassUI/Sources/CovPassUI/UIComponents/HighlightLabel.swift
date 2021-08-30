//
//  HighlightLabel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class HighlightLabel: UILabel {

    public override func awakeFromNib() {
        super.awakeFromNib()

        textColor = .neutralWhite
        backgroundColor = .resultRed
        clipsToBounds = true

        textInsets = .init(top: 2, left: 6, bottom: 2, right: 6)
    }

    public var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }

    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
