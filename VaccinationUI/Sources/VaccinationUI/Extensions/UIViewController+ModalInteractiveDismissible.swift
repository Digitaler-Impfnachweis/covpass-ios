//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 06.05.21.
//

import UIKit

extension UIViewController {
    public func modalInteractiveDismissible() -> ModalInteractiveDismissibleProtocol? {
        if let dissmisable = self as? ModalInteractiveDismissibleProtocol {
            return dissmisable
        }
        return (self as? UINavigationController)?.topViewController as? ModalInteractiveDismissibleProtocol
    }
}
