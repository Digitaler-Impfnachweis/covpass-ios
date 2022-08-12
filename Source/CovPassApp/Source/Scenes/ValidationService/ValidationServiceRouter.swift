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
            enum NoVerificationPossible {
                static let title = "error_share_certificate_no_verification_possible_title".localized
                static let message = "error_share_certificate_no_verification_possible_message".localized
                static let button = "error_share_certificate_no_verification_possible_action_button".localized
            }
            enum NoVerificationSubmissionPossible {
                static let title = "error_share_certificate_no_verification_submission_possible_title".localized
                static let message = "error_share_certificate_no_verification_submission_possible_message".localized
                static let button = "error_share_certificate_no_verification_submission_possible_action_button".localized
            }
            enum AccessTokenNotProcessed {
                static let title = "error_share_certificate_access_token_not_processed_title".localized
                static let message = "error_share_certificate_access_token_not_processed_message".localized
                static let button = "error_share_certificate_access_token_not_processed_action_button".localized
            }
            enum AccessTokenNotRetrieved {
                static let title = "error_share_certificate_access_token_not_retrieved_title".localized
                static let message = "error_share_certificate_access_token_not_retrieved_message".localized
                static let button = "error_share_certificate_access_token_not_retrieved_action_button".localized
            }
        }
    }
}

struct ValidationServiceRouter: ValidationServiceRoutable {
    var sceneCoordinator: SceneCoordinator
    
    func routeToConsentGeneralConsent() {
        
    }
    
    public func routeToWarning() -> Promise<Bool> {
        .init { resolver in
            showDialog(title: "",
                       message: Constants.Text.Alert.Cancellation.message,
                       actions: [
                        DialogAction(title: Constants.Text.Alert.Cancellation.ok, style: UIAlertAction.Style.default, isEnabled: true, completion: { _ in
                            return resolver.fulfill(false)
                        }),
                        DialogAction(title: Constants.Text.Alert.Cancellation.cancel, style: UIAlertAction.Style.destructive, isEnabled: true, completion: { _ in
                            sceneCoordinator.dimiss(animated: true)
                            return resolver.fulfill(true)
                        })],
                       style: .alert)
        }

    }    
    
    func showIdentityDocumentApiError(error: Error, provider: String) -> Promise<Bool> {
        Promise { resolver in
            let textKey = Constants.Text.Alert.ProviderNotVerified.message
            let formattedString = String(format: textKey, provider)
            showDialog(title: Constants.Text.Alert.ProviderNotVerified.title,
                       message: error.displayCodeWithMessage(formattedString),
                   actions: [
                    DialogAction(title: Constants.Text.Alert.ProviderNotVerified.button,
                                 style: UIAlertAction.Style.default,
                                 isEnabled: true,
                                 completion: { _ in
                                     routeToWarning().done { canceled in
                                         resolver.fulfill(canceled)
                                     }
                                     .cauterize()
                                 })
                    ],
                   style: .alert)
        }
    }
    
    func showIdentityDocumentVAASError(error: Error) -> Promise<Bool> {
        Promise { resolver in
        showDialog(title: Constants.Text.Alert.TestPartnerNotVerified.title,
                   message: error.displayCodeWithMessage(Constants.Text.Alert.TestPartnerNotVerified.message),
                   actions: [
                    DialogAction(title: Constants.Text.Alert.TestPartnerNotVerified.button,
                                 style: UIAlertAction.Style.default,
                                 isEnabled: true,
                                 completion: { _ in
                                     routeToWarning().done { canceled in
                                         resolver.fulfill(canceled)
                                     }
                                     .cauterize()
                                 })
                    ],
                   style: .alert)
        }
    }
    
    func accessTokenNotRetrieved(error: Error) -> Promise<Bool> {
        Promise { resolver in
        showDialog(title: Constants.Text.Alert.AccessTokenNotRetrieved.title,
                   message: error.displayCodeWithMessage(Constants.Text.Alert.AccessTokenNotRetrieved.message),
                   actions: [
                    DialogAction(title: Constants.Text.Alert.AccessTokenNotRetrieved.button,
                                 style: UIAlertAction.Style.default,
                                 isEnabled: true,
                                 completion: { _ in
                                     routeToWarning().done { canceled in
                                         resolver.fulfill(canceled)
                                     }
                                     .cauterize()
                                 })
                    ],
                   style: .alert)
        }
    }
    
    func showNoVerificationPossible(error: Error) -> Promise<Bool> {
        Promise { resolver in
        showDialog(title: Constants.Text.Alert.NoVerificationPossible.title,
                   message: error.displayCodeWithMessage(Constants.Text.Alert.NoVerificationPossible.message),
                   actions: [
                    DialogAction(title: Constants.Text.Alert.NoVerificationPossible.button,
                                 style: UIAlertAction.Style.default,
                                 isEnabled: true,
                                 completion: { _ in
                                     routeToWarning().done { canceled in
                                         resolver.fulfill(canceled)
                                     }
                                     .cauterize()
                                 })
                    ],
                   style: .alert)
        }
    }
    
    func showNoVerificationSubmissionPossible(error: Error) -> Promise<Bool> {
        Promise { resolver in
        showDialog(title: Constants.Text.Alert.NoVerificationSubmissionPossible.title,
                   message: error.displayCodeWithMessage(Constants.Text.Alert.NoVerificationSubmissionPossible.message),
                   actions: [
                    DialogAction(title: Constants.Text.Alert.NoVerificationSubmissionPossible.button,
                                 style: UIAlertAction.Style.default,
                                 isEnabled: true,
                                 completion: { _ in
                                     routeToWarning().done { canceled in
                                         resolver.fulfill(canceled)
                                     }
                                     .cauterize()
                                 })
                    ],
                   style: .alert)
        }
    }
    
    func showAccessTokenNotProcessed(error: Error) -> Promise<Bool> {
        Promise { resolver in
            showDialog(title: Constants.Text.Alert.AccessTokenNotProcessed.title,
                       message: error.displayCodeWithMessage(Constants.Text.Alert.AccessTokenNotProcessed.message),
                       actions: [
                        DialogAction(title: Constants.Text.Alert.AccessTokenNotProcessed.button,
                                     style: UIAlertAction.Style.default,
                                     isEnabled: true,
                                     completion: { _ in
                                         routeToWarning().done { canceled in
                                             resolver.fulfill(canceled)
                                         }
                                         .cauterize()
                                     })
                        ],
                       style: .alert)
        }
    }
    
    func routeToSelectCertificate(ticket: ValidationServiceInitialisation) {
        sceneCoordinator
            .push(
                ChooseCertificateSceneFactory(router: self, ticket: ticket),
                animated: true
            )
            .cauterize()
    }
    
    func routeToCertificateConsent(ticket: ValidationServiceInitialisation, certificate: ExtendedCBORWebToken, vaasRepository: VAASRepositoryProtocol) {
        sceneCoordinator.push(ConsentExchangeFactory(router: self, vaasRepository: vaasRepository, initialisationData: ticket, certificate: certificate))
    }
    
    func routeToPrivacyStatement(url: URL) {
        let webViewScene = WebviewSceneFactory(title: "app_information_title_datenschutz".localized,
                                               url: url,
                                               isToolbarShown: true,
                                               accessibilityAnnouncement: "accessibility_app_information_datenschutz_announce".localized)
        sceneCoordinator.push(webViewScene)
    }
    
    func showCertificate(_ certificate: ExtendedCBORWebToken,
                         with result: VAASValidaitonResultToken,
                         userDefaults: Persistence) {
        sceneCoordinator
            .push(
                ValidationResultSceneFactory(
                    router: ValidationResultRouter(sceneCoordinator: sceneCoordinator),
                    certificate: certificate,
                    error: nil,
                    token: result,
                    userDefaults: userDefaults
                )
            )
            .cauterize()
    }
    
    func showValidationFailed(ticket: ValidationServiceInitialisation) -> Promise<Bool>  {
        sceneCoordinator.present(
            ValidationFailedFactory(ticket: ticket)
        )
    }
}
