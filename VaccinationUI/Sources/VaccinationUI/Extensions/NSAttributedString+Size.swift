//
//  NSAttributedString+Size.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

extension NSAttributedString {
    func heightWithConstrainedWidth(_ width: CGFloat) -> CGFloat {
        sizeWithConstrainedWidth(width).height
    }

    func sizeWithConstrainedWidth(_ width: CGFloat) -> CGSize {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return boundingBox.size
    }
}
