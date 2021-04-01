//
//  UIViewExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol AutoLayoutContainer {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
}

extension UIView: AutoLayoutContainer {}
extension UILayoutGuide: AutoLayoutContainer {}

public extension AutoLayoutContainer {
    func centerX(of container: AutoLayoutContainer) {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
    }

    func centerY(of container: AutoLayoutContainer) {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
    }

    func setConstant(height: CGFloat) {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    @discardableResult
    func setConstant(width: CGFloat) -> [NSLayoutConstraint] {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let widthConstraint = widthAnchor.constraint(equalToConstant: width)
        widthConstraint.isActive = true
        return [widthConstraint]
    }
}
