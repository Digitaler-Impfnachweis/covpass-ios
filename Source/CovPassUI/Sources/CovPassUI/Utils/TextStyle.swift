//
//  TextStyle.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public enum TextStyle {
    case display
    case header_1
    case header_2
    case header_3
    case subheader_1
    case subheader_2
    case body
    case label
    case mainButton

    public func apply(_ string: NSAttributedString) -> NSAttributedString {
        switch self {
        case .display:
            return string
                .font(named: UIFont.sansBold, size: 36.0, lineHeight: 51.0, textStyle: .title2)
                .colored(.onBackground100)

        case .header_1:
            return string
                .font(named: UIFont.sansBold, size: 24.0, lineHeight: 36.0, textStyle: .title3)
                .colored(.onBackground100)

        case .header_2:
            return string
                .font(named: UIFont.sansBold, size: 18.0, lineHeight: 27.0, textStyle: .headline)
                .colored(.onBackground100)

        case .header_3:
            return string
                .font(named: UIFont.sansBold, size: 14.0, lineHeight: 21.0, textStyle: .subheadline)
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
