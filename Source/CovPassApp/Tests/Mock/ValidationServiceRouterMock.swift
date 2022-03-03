//
//  ValidationServiceRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import CovPassCommon
import PromiseKit
import Foundation
@testable import CovPassApp

struct ValidationServiceRouterMock: ValidationServiceRoutable {
    
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()

    func showCertificate(_ certificate: ExtendedCBORWebToken, with result: VAASValidaitonResultToken, userDefaults: Persistence) {
        
    }
    
    func showValidationFailed(ticket: ValidationServiceInitialisation) -> Promise<Bool> {
        .init { resolver in
            resolver.fulfill(true)
        }
    }

    func showIdentityDocumentApiError(error: Error, provider: String) -> Promise<Bool> {
        .init { resolver in
            resolver.fulfill(true)
        }
    }
    
    func showIdentityDocumentVAASError(error: Error) -> Promise<Bool>  {
        .init { resolver in
            resolver.fulfill(true)
        }
    }
    
    func accessTokenNotRetrieved(error: Error) -> Promise<Bool>  {
        .init { resolver in
            resolver.fulfill(true)
        }
    }
    
    func showNoVerificationPossible(error: Error) -> Promise<Bool>  {
        .init { resolver in
            resolver.fulfill(true)
        }
    }
    
    func showNoVerificationSubmissionPossible(error: Error) -> Promise<Bool>  {
        .init { resolver in
            resolver.fulfill(true)
        }
    }
    
    func showAccessTokenNotProcessed(error: Error) -> Promise<Bool>  {
        .init { resolver in
            resolver.fulfill(true)
        }
    }
    
    
    func routeToSelectCertificate(ticket: ValidationServiceInitialisation) {
        
    }
    
    func routeToCertificateConsent(ticket: ValidationServiceInitialisation, certificate: ExtendedCBORWebToken, vaasRepository: VAASRepositoryProtocol) {
        
    }
    
    func routeToCertificateValidationResult(for certificate: ExtendedCBORWebToken, with result: VAASValidaitonResultToken) {
        
    }
    
    func routeToConsentGeneralConsent() {
        
    }
    
    func routeToWarning() -> Promise<Bool>  {
        .init { resolver in
            resolver.fulfill(true)
        }
    }
    
    func routeToSelectCertificate() {
        
    }
    
    func routeToCertificateConsent() {
        
    }
    
    func routeToPrivacyStatement(url: URL) {
        
    }
    
    func showError2(error: Error) {
    }
    
    func showError3(error: Error) {
        
    }
    
    func showError4(error: Error) {
    }
    
    func showError5(error: Error) {
    }
}
