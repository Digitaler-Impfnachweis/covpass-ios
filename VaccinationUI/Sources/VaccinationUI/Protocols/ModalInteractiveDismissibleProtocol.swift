//
//  ModalInteractiveDismissibleProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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

extension ModalInteractiveDismissibleProtocol {
    public func canDismissModalViewController() -> Bool {
        true
    }

    public func modalViewControllerDidAttemptToDismiss() {}

    public func modalViewControllerDidDismiss() {}
}
