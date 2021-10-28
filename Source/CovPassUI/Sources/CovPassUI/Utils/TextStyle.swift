//
//  TextStyle.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public enum TextStyle {
    /// size: 34 lineHeight: 51 letterSpacing: 0.13 type: semi-bold color: onBackground100
    case display

    /// size: 28 lineHeight: 42 letterSpacing: 0.13 type: semi-bold color: onBackground100
    case header_1

    /// size: 18 lineHeight: 27 letterSpacing: 0.13 type: semi-bold color: onBackground100
    case header_2

    /// size: 14 lineHeight: 17 letterSpacing: 0.13 type: semi-bold color: onBackground100
    case header_3

    /// size: 18 lineHeight: 27 letterSpacing: 0.13 type: semi-bold color: onBackground100
    case subheader_1

    /// size: 14 lineHeight: 21 letterSpacing: 0.13 type: semi-bold color: onBackground70
    case subheader_2

    /// size: 14 lineHeight: 21 letterSpacing: 0.13 type: regular color: onBackground100
    case body

    /// size: 12 lineHeight: 18 letterSpacing: 0.13 type: regular color: onBackground100
    case label

    /// size: 14 lineHeight: 18 letterSpacing: 0.13 type: semi-bold color: onBackground100
    case mainButton

    public func apply(_ string: NSAttributedString) -> NSAttributedString {
        switch self {
        case .display:
            return string
                .font(named: UIFont.sansSemiBold, size: 36.0, lineHeight: 44.0, textStyle: .title2)
                .colored(.onBackground100)

        case .header_1:
            return string
                .font(named: UIFont.sansBold, size: 26.0, lineHeight: 38.0, textStyle: .title3)
                .colored(.onBackground100)

        case .header_2:
            return string
                .font(named: UIFont.sansBold, size: 18.0, lineHeight: 27.0, textStyle: .headline)
                .colored(.onBackground100)

        case .header_3:
            return string
                .font(named: UIFont.sansSemiBold, size: 14.0, lineHeight: 21.0, textStyle: .subheadline)
                .colored(.onBackground100)

        case .subheader_1:
            return string
                .font(named: UIFont.sansRegular, size: 18.0, lineHeight: 27.0, textStyle: .headline)
                .colored(.onBackground100)

        case .subheader_2:
            return string
                .font(named: UIFont.sansRegular, size: 14.0, lineHeight: 21.0, textStyle: .headline)
                .colored(.onBackground70)

        case .body:
            return string
                .font(named: UIFont.sansRegular, size: 14.0, lineHeight: 21.0, textStyle: .body)
                .colored(.onBackground100)

        case .label:
            return string
                .font(named: UIFont.sansRegular, size: 12.0, lineHeight: 18.0, textStyle: .body)
                .colored(.onBackground100)

        case .mainButton:
            return string
                .font(named: UIFont.sansSemiBold, size: 14.0, textStyle: .headline)
        }
    }
}
