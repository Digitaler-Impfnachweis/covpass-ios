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
            enum Cancellation {
                static let message = "cancellation_share_certificate_title".localized
                static let ok = "cancellation_share_certificate_action_button_no".localized
                static let cancel = "cancellation_share_certificate_action_button_yes".localized
            }
            enum ProviderNotVerified {
                static let title = "error_share_certificate_provider_not_verified_title".localized
                static let message = "error_share_certificate_provider_not_verified_message".localized
                static let button = "error_share_certificate_provider_not_verified_action_button".localized
            }
            enum TestPartnerNotVerified {
                static let title = "error_share_certificate_test_partner_not_verified_title".localized
                static let message = "error_share_certificate_test_partner_not_verified_message".localized
                static let button = "error_share_certificate_test_partner_not_verified_action_button".localized
            }
            enum NoConnectionToProvider {
                static let title = "error_share_certificate_no_connection_to_provider_title".localized
                static let message = "error_share_certificate_no_connection_to_provider_message".localized
                static let button = "error_share_certificate_no_connection_to_provider_action_button".localized
            }
            enum NoVerificationPossible {
                static let title = "error_share_certificate_no_verification_possible_title".localized
                static let message = "error_share_certificate_no_verification_possible_message".localized
                static let button = "error_share_certificate_no_verification_possible_action_button".localized
            }
        }
    }
}

protocol ValidationServiceRoutable: DialogRouterProtocol {
    func routeToConsentGeneralConsent()
    func routeToWarning()
    func showError2(error: Error)
    func showError3(error: Error)
    func showError4(error: Error)
    func showError5(error: Error)
    func routeToSelectCertificate(ticket: ValidationServiceInitialisation)
    func routeToCertificateConsent(ticket: ValidationServiceInitialisation, certificate: ExtendedCBORWebToken, vaasRepository: VAASRepositoryProtocol)
    func routeToPrivacyStatement(url: URL)
    func routeToCertificateValidation(for certificate: ExtendedCBORWebToken)
}

struct ValidationServiceRouter: ValidationServiceRoutable {
    var sceneCoordinator: SceneCoordinator
    
    func routeToConsentGeneralConsent() {
        
    }
    
    public func routeToWarning() {
        showDialog(title: "",
                   message: Constants.Text.Alert.Cancellation.message,
                   actions: [
                    DialogAction(title: Constants.Text.Alert.Cancellation.ok, style: UIAlertAction.Style.default, isEnabled: true, completion: nil),
                    DialogAction(title: Constants.Text.Alert.Cancellation.cancel, style: UIAlertAction.Style.destructive, isEnabled: true, completion: { _ in
                        sceneCoordinator.dimiss(animated: true)
                    })],
                   style: .alert)
    }
    
    func showError2(error: Error) {
        showDialog(title: Constants.Text.Alert.ProviderNotVerified.title,
                   message: error.displayCodeWithMessage(Constants.Text.Alert.ProviderNotVerified.message),
                   actions: [
                    DialogAction(title: Constants.Text.Alert.ProviderNotVerified.button,
                                 style: UIAlertAction.Style.default,
                                 isEnabled: true,
                                 completion: { _ in
                                     sceneCoordinator.dimiss(animated: true)
                                 })
                    ],
                   style: .alert)
    }
    
    func showError3(error: Error) {
        showDialog(title: Constants.Text.Alert.TestPartnerNotVerified.title,
                   message: error.displayCodeWithMessage(Constants.Text.Alert.TestPartnerNotVerified.message),
                   actions: [
                    DialogAction(title: Constants.Text.Alert.TestPartnerNotVerified.button,
                                 style: UIAlertAction.Style.default,
                                 isEnabled: true,
                                 completion: { _ in
                                     sceneCoordinator.dimiss(animated: true)
                                 })
                    ],
                   style: .alert)
    }
    
    func showError4(error: Error) {
        showDialog(title: Constants.Text.Alert.NoConnectionToProvider.title,
                   message: error.displayCodeWithMessage(Constants.Text.Alert.NoConnectionToProvider.message),
                   actions: [
                    DialogAction(title: Constants.Text.Alert.NoConnectionToProvider.button,
                                 style: UIAlertAction.Style.default,
                                 isEnabled: true,
                                 completion: { _ in
                                     sceneCoordinator.dimiss(animated: true)
                                 })
                    ],
                   style: .alert)
    }
    
    func showError5(error: Error) {
        showDialog(title: Constants.Text.Alert.NoVerificationPossible.title,
                   message: error.displayCodeWithMessage(Constants.Text.Alert.NoVerificationPossible.message),
                   actions: [
                    DialogAction(title: Constants.Text.Alert.NoVerificationPossible.button,
                                 style: UIAlertAction.Style.default,
                                 isEnabled: true,
                                 completion: { _ in
                                     sceneCoordinator.dimiss(animated: true)
                                 })
                    ],
                   style: .alert)
    }
    
    func routeToSelectCertificate(ticket: ValidationServiceInitialisation) {
        sceneCoordinator.push(
            ChooseCertificateSceneFactory(
                router: self,
                ticket: ticket
            ),
            animated: true)
    }
    
    func routeToCertificateConsent(ticket: ValidationServiceInitialisation, certificate: ExtendedCBORWebToken, vaasRepository: VAASRepositoryProtocol) {
        sceneCoordinator.push(ConsentExchangeFactory(router: self, vaasRepository: vaasRepository, initialisationData: ticket, certificate: certificate))
    }
    
    func routeToPrivacyStatement(url: URL) {
        let webViewScene = WebviewSceneFactory(title: "app_information_title_datenschutz".localized,
                                               url: url, isToolbarShown: true)
        sceneCoordinator.push(webViewScene)
    }
    
    func routeToCertificateValidation(for certificate: ExtendedCBORWebToken) {
        sceneCoordinator.push(
            CertificateItemDetailSceneFactory(
                router: CertificateItemDetailRouter(sceneCoordinator: sceneCoordinator),
                certificate: certificate
            )
        )
    }
}
