//
//  ModalSceneContext.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
        getDismissible(from: presentationController.presentedViewController)?.canDismissModalViewController() ?? true
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        getDismissible(from: presentationController.presentedViewController)?.modalViewControllerDidAttemptToDismiss()
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        getDismissible(from: presentationController.presentedViewController)?.modalViewControllerDidDismiss()
    }

    private func getDismissible(from viewController: UIViewController) -> ModalInteractiveDismissibleProtocol? {
        if let dissmisable = viewController as? ModalInteractiveDismissibleProtocol {
            return dissmisable
        }
        return (viewController as? UINavigationController)?.topViewController as? ModalInteractiveDismissibleProtocol
    }
}
