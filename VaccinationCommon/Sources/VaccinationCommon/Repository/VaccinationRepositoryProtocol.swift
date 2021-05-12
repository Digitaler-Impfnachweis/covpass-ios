//
//  VaccinationRepositoryProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import Keychain
import PromiseKit

public protocol VaccinationRepositoryProtocol {
    /// Return the vaccination certificate list
    func getVaccinationCertificateList() -> Promise<VaccinationCertificateList>

    /// Save the vaccination certificate list
    func saveVaccinationCertificateList(_ certificateList: VaccinationCertificateList) -> Promise<VaccinationCertificateList>

    /// Refreshes the local validation CA
    func refreshValidationCA() -> Promise<Void>

    /// scanVaccinationCertificate validates the given QR code, parses it, interacts with the HealthCertificateBackend to retrieve the ValidationCertificate and returns everything as an ExtendedVaccinationCertificate.
    ///
    /// If an error occurs, the method will not return a certificate but an error
    ///
    /// - USED BY VaccinationPass App
    func scanVaccinationCertificate(_ data: String) -> Promise<ExtendedCBORWebToken>

    /// reissueValidationCertificate will send the vaccination certificate to the backend to issue a new validation certificate
    ///
    /// - USED BY VaccinationPass App
    func reissueValidationCertificate(_ certificate: ExtendedCBORWebToken) -> Promise<ExtendedCBORWebToken>

    /// checkValidationCertificate validates the given QR code and returns the ValidationCertificate when it's valid, otherwise an error
    ///
    /// - USED BY VaccinationValidator App
    func checkValidationCertificate(_ data: String) -> Promise<CBORWebToken>
}
