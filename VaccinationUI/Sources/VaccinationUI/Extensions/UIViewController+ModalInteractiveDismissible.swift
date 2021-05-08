//
//  UIViewController+ModalInteractiveDismissible.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
