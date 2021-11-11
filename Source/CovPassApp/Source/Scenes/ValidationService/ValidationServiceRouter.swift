//
//  ValidationServiceRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    enum Text {
        enum Alert {
            static let message = "Wollen Sie den Vorgang wirklich beenden?"
            static let ok = "Nicht jetzt"
            static let cancel = "Ja, beenden"
        }
    }
}

protocol ValidationServiceRoutable: DialogRouterProtocol {
    func routeToConsentGeneralConsent()
    func routeToWarning()
    func routeToSelectCertificate()
    func routeToCertificateConsent()
    func routeToPrivacyStatement(url: String)
}

struct ValidationServiceRouter: ValidationServiceRoutable {
    var sceneCoordinator: SceneCoordinator

    func routeToConsentGeneralConsent() {

    }

    public func routeToWarning() {
        showDialog(title: "",
                   message: Constants.Text.Alert.message,
                   actions: [
                    DialogAction(title: Constants.Text.Alert.ok, style: UIAlertAction.Style.default, isEnabled: true, completion: nil),
                    DialogAction(title: Constants.Text.Alert.cancel, style: UIAlertAction.Style.destructive, isEnabled: true, completion: { _ in
                        sceneCoordinator.dimiss(animated: true)
                    })],
                   style: .alert)
    }

    func routeToSelectCertificate() {

    }

    func routeToCertificateConsent() {

    }

    func routeToPrivacyStatement(url: String) {
        let webViewScene = WebviewSceneFactory(title: "app_information_title_faq".localized,
                                               url: URL(string: url)!, closeButtonShown: true, embedInNavigationController: true)
        sceneCoordinator.present(webViewScene)
    }
}
