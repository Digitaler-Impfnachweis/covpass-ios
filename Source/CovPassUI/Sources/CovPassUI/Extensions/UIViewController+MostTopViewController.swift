//
//  UIViewController+TopViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

extension UIViewController {
    var mostTopViewController: UIViewController? {
        var topViewController: UIViewController? = self
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        return topViewController
    }
}
