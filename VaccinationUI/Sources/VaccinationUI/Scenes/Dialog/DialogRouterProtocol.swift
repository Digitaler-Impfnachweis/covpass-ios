//
//  DialogRouterProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit

public protocol DialogRouterProtocol: RouterProtocol {
    func showDialog(
        title: String?,
        message: String?,
        actions: [DialogAction],
        style: UIAlertController.Style
    )
}

public extension DialogRouterProtocol {
    func showDialog(
        title: String?,
        message: String?,
        actions: [DialogAction],
        style: UIAlertController.Style
    ) {
        sceneCoordinator.present(
            AlertSceneFactory(title: title, message: message, actions: actions, style: style)
        )
        .cauterize()
    }
}
