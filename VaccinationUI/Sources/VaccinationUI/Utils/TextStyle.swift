//
//  TextStyle.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public enum TextStyle {
    /// size: 64 type: semi-bold color: neutralBlack
    case h1

    /// size: 42 type: semi-bold color: neutralBlack
    case h2

    /// size: 28 type: semi-bold color: neutralBlack
    case h3

    /// size: 20 type: semi-bold color: neutralBlack
    case h4

    /// size: 16 type: semi-bold color: neutralBlack
    case h5

    /// size: 14 type: semi-bold color: neutralBlack
    case h6

    /// size: 16 type: regular color: neutralBlack
    case body

    public func apply(_ string: NSAttributedString) -> NSAttributedString {
        switch self {
        case .h1:
            return string
                .font(named: UIFont.sansSemiBold, size: 64.0, lineHeight: 72.0, textStyle: .title1)
                .letterSpacing(0.12)
                .colored(.neutralBlack)

        case .h2:
            return string
                .font(named: UIFont.sansSemiBold, size: 42.0, lineHeight: 48.0, textStyle: .title2)
                .letterSpacing(0.12)
                .colored(.neutralBlack)

        case .h3:
            return string
                .font(named: UIFont.sansSemiBold, size: 28.0, lineHeight: 32.0, textStyle: .title3)
                .letterSpacing(0.12)
                .colored(.neutralBlack)

        case .h4:
            return string
                .font(named: UIFont.sansSemiBold, size: 20.0, lineHeight: 24.0, textStyle: .headline)
                .letterSpacing(0.12)
                .colored(.neutralBlack)

        case .h5:
            return string
                .font(named: UIFont.sansSemiBold, size: 16.0, lineHeight: 24.0, textStyle: .subheadline)
                .letterSpacing(0.12)
                .colored(.neutralBlack)

        case .h6:
            return string
                .font(named: UIFont.sansSemiBold, size: 14.0, lineHeight: 20.0, textStyle: .subheadline)
                .letterSpacing(0.12)
                .colored(.neutralBlack)

        case .body:
            return string
                .font(named: UIFont.sansRegular, size: 16.0, textStyle: .body)
                .letterSpacing(0.12)
                .colored(.neutralBlack)
        }
    }
}
