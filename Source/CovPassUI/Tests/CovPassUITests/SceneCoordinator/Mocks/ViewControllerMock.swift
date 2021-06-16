//
//  ViewControllerMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class ViewControllerMock: UIViewController {
    var didDismiss: (() -> Void)?
    var currentPresentedViewController: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated _: Bool, completion _: (() -> Void)? = nil) {
        currentPresentedViewController = viewControllerToPresent
    }

    override var presentedViewController: UIViewController? {
        currentPresentedViewController
    }

    override func dismiss(animated _: Bool, completion: (() -> Void)? = nil) {
        didDismiss?()
        completion?()
    }
}

class InteractiveDismissibleViewControllerMock: ViewControllerMock, ModalInteractiveDismissibleProtocol {
    var canDismiss = true
    func canDismissModalViewController() -> Bool {
        canDismiss
    }

    var didAttemptToDismiss: (() -> Void)?
    func modalViewControllerDidAttemptToDismiss() {
        didAttemptToDismiss?()
    }

    func modalViewControllerDidDismiss() {
        didDismiss?()
    }
}
