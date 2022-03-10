//
//  VaccinationRepositoryProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public protocol VaccinationRepositoryProtocol {
    /// Return the stored certificate list
    func getCertificateList() -> Promise<CertificateList>

    /// Save the certificate list
    func saveCertificateList(_ certificateList: CertificateList) -> Promise<CertificateList>

    /// Saves an array of tokens. Does not overwrite the existing tokens, but appends the new tokens.
    /// It is not checked, if the tokens already exist.
    func add(tokens: [ExtendedCBORWebToken]) -> Promise<Void>

    /// Update the local trust list
    func updateTrustListIfNeeded() -> Promise<Void>

    /// Update the local trust list once a day
    func updateTrustList() -> Promise<Void>

    /// Deletes the given certificate from the certificate list
    func delete(_ certificate: ExtendedCBORWebToken) -> Promise<Void>

    /// scanCertificate validates the given QR code, parses it, and returns everything as an ExtendedCBORWebToken.
    ///
    /// If an error occurs, the method will not return a certificate but an error
    ///
    /// - USED BY CovPass App
    func scanCertificate(_ data: String, isCountRuleEnabled: Bool) -> Promise<QRCodeScanable>
    
    /// checkCertificate validates the given QR code and returns the  certificate when it's valid, otherwise an error
    ///
    /// - USED BY CovPassCheck App
    func checkCertificate(_ data: String) -> Promise<CBORWebToken>

    /// Toogles the favorite state and returns the updated flag
    func toggleFavoriteStateForCertificateWithIdentifier(_ id: String) -> Promise<Bool>

    /// Set's the flag if the expiry alert view for the tokens should be shown or not
    func setExpiryAlert(shown: Bool, tokens: [ExtendedCBORWebToken]) -> Promise<Void>
    
    /// Set's the flag if the reissue alert view for the token should be shown or not
    func setReissueProcess(initialAlreadySeen: Bool,
                           newBadgeAlreadySeen: Bool,
                           tokens: [ExtendedCBORWebToken]) -> Promise<Void>
    
    /// Returns true if collection contains a favorite certificate. False otherwise.
    func favoriteStateForCertificates(_ certificates: [ExtendedCBORWebToken]) -> Promise<Bool>
    
    /// Returns all certificates matched based on name and birthdate
    func matchedCertificates(for certificateList: CertificateList) -> [CertificatePair]
    
    func trustListShouldBeUpdated() -> Promise<Bool>
    
    func trustListShouldBeUpdated() -> Bool
}
