//
//  NavigationSceneReference.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

class NavigationSceneReference {
    // MARK: - Properties

    let viewController: UIViewController
    var didPop: ((UIViewController) -> Void)?

    // MARK: - Lifecycle

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    // MARK: - Methods

    func navigationController(_ navigationController: UINavigationController, didShow _: UIViewController, animated _: Bool) {
        // Assuming current ViewController reference did already pop if it's not part of the navigation stack anymore.
        if navigationController.viewControllers.contains(viewController) == false {
            didPop?(viewController)
        }
    }
}
