//
//  UIScrollView+BottomScroll.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

enum ScrollDirection {
    case top
    case bottom
}

extension UIScrollView {
    /// Returns 'true' if the scrollView is scrolled all the way to the bottom of it's content, 'false' if not.
    var isScrolledToBottom: Bool {
        return contentOffset.y + 1 >= contentSize.height - frame.size.height
    }

    /// Scrolls automatically to the specified direction.
    /// - parameter direction: The direction of the scrolling.
    /// - parameter inset: The content inset if there is any
    /// - parameter animated: Specifies if the scroll should happen animated or not.
    func scroll(to direction: ScrollDirection, with inset: CGFloat = 0, animated: Bool) {
        let contentOffset: CGPoint!
        switch direction {
        case .top:
            contentOffset = .zero
        case .bottom:
            contentOffset = CGPoint(x: 0, y: contentSize.height - bounds.height + inset)
        }
        setContentOffset(contentOffset, animated: animated)
    }
}
