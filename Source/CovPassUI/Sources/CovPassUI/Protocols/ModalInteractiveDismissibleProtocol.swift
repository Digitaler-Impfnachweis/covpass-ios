//
//  ModalInteractiveDismissibleProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol ModalInteractiveDismissibleProtocol {
    // Return false to prevent dismissal of the view controller.
    func canDismissModalViewController() -> Bool

    /// When this method is called, inform user why they cannot dismiss the view controller.
    func modalViewControllerDidAttemptToDismiss()

    /// This method is called, when user dismissed the view controller.
    func modalViewControllerDidDismiss()
}

public extension ModalInteractiveDismissibleProtocol {
    func canDismissModalViewController() -> Bool {
        true
    }

    func modalViewControllerDidAttemptToDismiss() {}

    func modalViewControllerDidDismiss() {}
}
