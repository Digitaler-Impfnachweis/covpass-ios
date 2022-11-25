//
//  ValidationServiceRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit

struct ValidationServiceRouterMock: ValidationServiceRoutable {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()

    func showCertificate(_: ExtendedCBORWebToken, with _: VAASValidaitonResultToken, userDefaults _: Persistence) {}

    func showValidationFailed(ticket _: ValidationServiceInitialisation) -> Promise<Bool> {
        .init { resolver in
            resolver.fulfill(true)
        }
    }

    func showIdentityDocumentApiError(error _: Error, provider _: String) -> Promise<Bool> {
        .init { resolver in
            resolver.fulfill(true)
        }
    }

    func showIdentityDocumentVAASError(error _: Error) -> Promise<Bool> {
        .init { resolver in
            resolver.fulfill(true)
        }
    }

    func accessTokenNotRetrieved(error _: Error) -> Promise<Bool> {
        .init { resolver in
            resolver.fulfill(true)
        }
    }

    func showNoVerificationPossible(error _: Error) -> Promise<Bool> {
        .init { resolver in
            resolver.fulfill(true)
        }
    }

    func showNoVerificationSubmissionPossible(error _: Error) -> Promise<Bool> {
        .init { resolver in
            resolver.fulfill(true)
        }
    }

    func showAccessTokenNotProcessed(error _: Error) -> Promise<Bool> {
        .init { resolver in
            resolver.fulfill(true)
        }
    }

    func routeToSelectCertificate(ticket _: ValidationServiceInitialisation) {}

    func routeToCertificateConsent(ticket _: ValidationServiceInitialisation, certificate _: ExtendedCBORWebToken, vaasRepository _: VAASRepositoryProtocol) {}

    func routeToCertificateValidationResult(for _: ExtendedCBORWebToken, with _: VAASValidaitonResultToken) {}

    func routeToConsentGeneralConsent() {}

    func routeToWarning() -> Promise<Bool> {
        .init { resolver in
            resolver.fulfill(true)
        }
    }

    func routeToSelectCertificate() {}

    func routeToCertificateConsent() {}

    func routeToPrivacyStatement(url _: URL) {}

    func showError2(error _: Error) {}

    func showError3(error _: Error) {}

    func showError4(error _: Error) {}

    func showError5(error _: Error) {}
}
