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

    /// Get the date when the trust list got updated last
    func getLastUpdatedTrustList() -> Date?

    /// Update the local trust list once a day
    func updateTrustList() -> Promise<Void>

    /// Deletes the given certificate from the certificate list
    func delete(_ certificate: ExtendedCBORWebToken) -> Promise<Void>

    /// scanCertificate validates the given QR code, parses it, and returns everything as an ExtendedCBORWebToken.
    ///
    /// If an error occurs, the method will not return a certificate but an error
    ///
    /// - USED BY CovPass App
    func scanCertificate(_ data: String) -> Promise<ExtendedCBORWebToken>

    /// checkCertificate validates the given QR code and returns the  certificate when it's valid, otherwise an error
    ///
    /// - USED BY CovPassCheck App
    func checkCertificate(_ data: String) -> Promise<CBORWebToken>

    /// Toogles the favorite state and returns the updated flag
    func toggleFavoriteStateForCertificateWithIdentifier(_ id: String) -> Promise<Bool>

    /// Returns true if collection contains a favorite certificate. False otherwise.
    func favoriteStateForCertificates(_ certificates: [ExtendedCBORWebToken]) -> Promise<Bool>
}
