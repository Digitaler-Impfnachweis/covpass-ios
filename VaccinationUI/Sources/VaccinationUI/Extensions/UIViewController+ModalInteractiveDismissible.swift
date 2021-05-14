//
//  UIViewController+ModalInteractiveDismissible.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public extension UIViewController {
    func modalInteractiveDismissible() -> ModalInteractiveDismissibleProtocol? {
        if let dissmisable = self as? ModalInteractiveDismissibleProtocol {
            return dissmisable
        }
        return (self as? UINavigationController)?.topViewController as? ModalInteractiveDismissibleProtocol
    }
}
