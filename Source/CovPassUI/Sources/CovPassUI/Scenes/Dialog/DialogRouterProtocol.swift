//
//  DialogRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
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

    func showUnexpectedErrorDialog(_ error: Error)
    
    func showNoInternetErrorDialog(_ error: Error)
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

    func showUnexpectedErrorDialog(_ error: Error) {
        let scene = AlertSceneFactory(
            title: "error_standard_unexpected_title".localized,
            message: error.displayCodeWithMessage("error_standard_unexpected_message".localized),
            actions: [DialogAction(title: "error_connect_to_internet_Button_ok".localized)],
            style: .alert
        )
        sceneCoordinator.present(scene).cauterize()
    }
    
    func showNoInternetErrorDialog(_ error: Error) {
        let scene = AlertSceneFactory(
            title: "error_no_connection_to_server_title".localized(bundle: .main),
            message: error.displayCodeWithMessage("error_no_connection_to_server_message".localized(bundle: .main)),
            actions: [DialogAction(title: "error_connect_to_internet_button_ok".localized(bundle: .uiBundle))],
            style: .alert
        )
        sceneCoordinator.present(scene).cauterize()
    }
}
