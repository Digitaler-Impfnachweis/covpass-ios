//
//  UIViewExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
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

    @discardableResult
    func setConstant(size: CGSize) -> [NSLayoutConstraint] {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let widthConstraint = widthAnchor.constraint(equalToConstant: size.width)
        let heightConstraint = heightAnchor.constraint(equalToConstant: size.height)
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        return [widthConstraint, heightConstraint]
    }

    func pinEdges(_ edges: UIRectEdge = .all, to container: AutoLayoutContainer, margins: UIEdgeInsets = .zero) {
        (self as? UIView)?.translatesAutoresizingMaskIntoConstraints = false

        if edges.contains(.top) {
            topAnchor.constraint(equalTo: container.topAnchor, constant: margins.top).isActive = true
        }
        if edges.contains(.left) {
            leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: margins.left).isActive = true
        }
        if edges.contains(.bottom) {
            bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -margins.bottom).isActive = true
        }
        if edges.contains(.right) {
            trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -margins.right).isActive = true
        }
    }
}

extension UIView {
    public func updateFocusBorderView(customFrame: CGRect? = nil) {
        FocusBorderManager.shared.updateFocusBorderView(customFrame: customFrame, view: self)
    }
}
