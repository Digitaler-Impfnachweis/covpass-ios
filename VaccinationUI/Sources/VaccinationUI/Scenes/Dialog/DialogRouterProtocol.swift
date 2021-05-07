//
//  DialogRouterProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit

public protocol DialogRouterProtocol: RouterProtocol {
    func showDialog(
        title: String?,
        message: String?,
        actions: [DialogAction],
        style: UIAlertController.Style
    )
}

extension DialogRouterProtocol {
    public func showDialog(
        title: String?,
        message: String?,
        actions: [DialogAction],
        style: UIAlertController.Style) {

        sceneCoordinator.present(
            AlertSceneFactory(title: title, message: message, actions: actions, style: style)
        )
        .cauterize()
    }
}
