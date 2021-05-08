//
//  NSAttributedString+Size.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
