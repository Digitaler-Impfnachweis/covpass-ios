//
//  ConsentExchangeRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit
import UIKit

private enum Constants {
    enum Text {
        enum Alert {
            static let message = "cancellation_share_certificate_title".localized
            static let ok = "cancellation_share_certificate_action_button_no".localized
            static let cancel = "cancellation_share_certificate_action_button_yes".localized
        }
    }
}

protocol ConsentExchangeRoutable: DialogRouterProtocol {
    func routeToWarning()
    func routeToPrivacyStatement(url: URL)
}

struct ConsentExchangeRouter: ConsentExchangeRoutable {
    var sceneCoordinator: SceneCoordinator

    public func routeToWarning() {
        showDialog(title: "",
                   message: Constants.Text.Alert.message,
                   actions: [
                       DialogAction(title: Constants.Text.Alert.ok, style: UIAlertAction.Style.default, isEnabled: true, completion: nil),
                       DialogAction(title: Constants.Text.Alert.cancel, style: UIAlertAction.Style.destructive, isEnabled: true, completion: { _ in
                           sceneCoordinator.dimiss(animated: true)
                       })
                   ],
                   style: .alert)
    }

    func routeToPrivacyStatement(url: URL) {
        let scene = WebviewSceneFactory(title: "app_information_title_datenschutz".localized,
                                        url: url,
                                        isToolbarShown: true,
                                        openingAnnounce: "accessibility_app_information_datenschutz_announce".localized,
                                        closingAnnounce: "accessibility_app_information_datenschutz_closing_announce".localized)
        sceneCoordinator.push(scene)
    }
}
