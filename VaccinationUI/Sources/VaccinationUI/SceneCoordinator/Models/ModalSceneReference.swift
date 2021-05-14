//
//  ModalSceneContext.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

class ModalSceneReference: NSObject, UIAdaptivePresentationControllerDelegate {
    // MARK: - Lifecycle

    init(viewController: UIViewController) {
        super.init()
        viewController.presentationController?.delegate = self
    }

    // MARK: - Methods

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        presentationController
            .presentedViewController
            .modalInteractiveDismissible()?
            .canDismissModalViewController()
            ?? true
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        presentationController
            .presentedViewController
            .modalInteractiveDismissible()?
            .modalViewControllerDidAttemptToDismiss()
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presentationController
            .presentedViewController
            .modalInteractiveDismissible()?
            .modalViewControllerDidDismiss()
    }
}
