//
//  UIViewController+TopViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
