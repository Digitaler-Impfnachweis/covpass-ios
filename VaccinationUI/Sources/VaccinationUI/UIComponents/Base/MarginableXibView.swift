//
//  MarginableXibView.swift
// 
//
//  This is a subclass of XibView that adds adjustable
//  margin constraints to the view.
//
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit

open class MarginableXibView: XibView, Marginable, UIGestureRecognizerDelegate {
    @IBOutlet public var topLayoutConstraint: NSLayoutConstraint?
    @IBOutlet public var rightLayoutConstraint: NSLayoutConstraint?
    @IBOutlet public var bottomLayoutConstraint: NSLayoutConstraint?
    @IBOutlet public var leftLayoutConstraint: NSLayoutConstraint?

    internal var didCancelTouch: Bool = false

    @objc public dynamic var viewType: UIView.Type {
        return type(of: self)
    }

    open var margins: [Margin] {
        return []
    }

    public var keepDefinedTopMargin: Bool = false

    open var shouldAutomaticallySetTopMargin: Bool {
        return !keepDefinedTopMargin
    }

    // MARK: Styleable

    public func setMargin(_ margin: Margin) {
        switch margin.type {
        case .top:
            topLayoutConstraint?.constant = margin.constant
        case .right:
            rightLayoutConstraint?.constant = margin.constant
        case .bottom:
            bottomLayoutConstraint?.constant = margin.constant
        case .left:
            leftLayoutConstraint?.constant = margin.constant
        }
    }

    @objc(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:) public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}
