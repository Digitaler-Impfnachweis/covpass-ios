//
//  ValidationServiceRoutableProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import CovPassCommon
import Foundation

protocol ValidationServiceRoutable: DialogRouterProtocol {
    func routeToConsentGeneralConsent()
    func routeToWarning() -> Promise<Bool>
    func showIdentityDocumentApiError(error: Error, provider: String) -> Promise<Bool>
    func showIdentityDocumentVAASError(error: Error) -> Promise<Bool>
    func accessTokenNotRetrieved(error: Error) -> Promise<Bool>
    func showNoVerificationPossible(error: Error) -> Promise<Bool>
    func showNoVerificationSubmissionPossible(error: Error) -> Promise<Bool>
    func showAccessTokenNotProcessed(error: Error) -> Promise<Bool>
    func routeToSelectCertificate(ticket: ValidationServiceInitialisation)
    func routeToCertificateConsent(ticket: ValidationServiceInitialisation, certificate: ExtendedCBORWebToken, vaasRepository: VAASRepositoryProtocol)
    func routeToPrivacyStatement(url: URL)
    func showCertificate(_ certificate: ExtendedCBORWebToken, with result: VAASValidaitonResultToken)
}
