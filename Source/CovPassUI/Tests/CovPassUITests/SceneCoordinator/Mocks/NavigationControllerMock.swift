//
//  NavigationControllerMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

class NavigationControllerMock: UINavigationController {
    var currentViewControllers = [UIViewController]()
    var currentPresentedViewController: UIViewController?

    var didPush: ((UIViewController?) -> Void)?
    var didPop: ((UIViewController?) -> Void)?
    var didPresent: ((UIViewController?) -> Void)?

    override var viewControllers: [UIViewController] {
        get { currentViewControllers }
        set { currentViewControllers = newValue }
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        defer {
            delegate?.navigationController?(self, didShow: viewController, animated: animated)
        }
        currentViewControllers.append(viewController)
        didPush?(viewController)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let vc = currentViewControllers.popLast()
        defer {
            if let nextViewController = currentViewControllers.last {
                delegate?.navigationController?(self, didShow: nextViewController, animated: animated)
            }
            didPop?(vc)
        }
        return vc
    }

    override func present(_ viewControllerToPresent: UIViewController, animated _: Bool, completion _: (() -> Void)? = nil) {
        currentPresentedViewController = viewControllerToPresent
        didPresent?(currentPresentedViewController)
    }

    override var presentedViewController: UIViewController? {
        currentPresentedViewController
    }
}
