//
//  Textable.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol Textable: AnyObject {
    associatedtype ViewType: UIView
    var textableView: ViewType! { get set }
    var attributedText: NSAttributedString? { get set }
}

extension Textable where ViewType == UILabel {
    public var attributedText: NSAttributedString? {
        get {
            textableView.attributedText
        }
        set {
            textableView.attributedText = newValue
        }
    }
}

extension Textable where ViewType == UIButton {
    public var attributedText: NSAttributedString? {
        get {
            textableView.attributedTitle(for: .normal)
        }
        set {
            textableView.setAttributedTitle(newValue, for: .normal)
            // only needed for the interface builder to display the button text
            textableView.titleLabel?.attributedText = newValue
        }
    }
}

extension Textable where ViewType == UITextField {
    public var attributedText: NSAttributedString? {
        get {
            textableView.attributedText
        }
        set {
            textableView.attributedText = newValue
        }
    }
}

extension Textable where ViewType == UITextView {
    public var attributedText: NSAttributedString? {
        get {
            textableView.attributedText
        }
        set {
            textableView.attributedText = newValue
        }
    }
}
