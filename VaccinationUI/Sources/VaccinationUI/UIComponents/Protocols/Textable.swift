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
    var text: String? { get set }
}

extension Textable where ViewType == UILabel {
    public var text: String? {
        get {
            return textableView.text
        }
        set {
            textableView.text = newValue
        }
    }
}

extension Textable where ViewType == UIButton {
    public var text: String? {
        get {
            return textableView.titleLabel?.text
        }
        set {
            textableView.setTitle(newValue, for: .normal)

            // only needed for the interface builder to display the button text
            textableView.titleLabel?.text = newValue
        }
    }
}

extension Textable where ViewType == UITextField {
    public var text: String? {
        get {
            return textableView.text
        }
        set {
            textableView.text = newValue
        }
    }
}

extension Textable where ViewType == UITextView {
    public var text: String? {
        get {
            return textableView.text
        }
        set {
            textableView.text = newValue
        }
    }
}
