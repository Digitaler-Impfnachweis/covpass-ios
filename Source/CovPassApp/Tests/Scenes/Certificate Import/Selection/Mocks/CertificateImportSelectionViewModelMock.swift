//
//  CertificateImportSelectionViewModelMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import XCTest

final class CertificateImportSelectionViewModelMock: CertificateImportSelectionViewModelProtocol {
    var delegate: ViewModelDelegate?
    var isImportingCertificates = false
    let importCertificatesExpectation = XCTestExpectation(description: "importCertificatesExpectation")
    var itemSelectionState: CertificateImportSelectionState = .none
    var enableButton = true
    var hideSelection = false
    var title = "Select certificates"
    var buttonTitle = "Import certificates"
    var selectionTitle = "Certificate(s) selected"
    var hintTitle = "If a certificate is missing:"
    var hintTextBulletPoints = [
        "Check whether there is a QR code in the selected file.",
        "Note that no expired or revoked certificates can be imported.",
        "Take a screenshot of the QR code in question and import it again as a photo."
    ]
    var items: [CertificateImportSelectionItem] = [
        VaccinationImportSelectionItem(token: CBORWebToken.mockVaccinationCertificate.extended()),
        RecoveryImportSelectionItem(token: CBORWebToken.mockRecoveryCertificate.extended()),
        TestImportSelectionItem(token: CBORWebToken.mockTestCertificateWithFixedSc.extended()),
        VaccinationImportSelectionItem(token: CBORWebToken.mockVaccinationCertificate.extended()),
        RecoveryImportSelectionItem(token: CBORWebToken.mockRecoveryCertificate.extended()),
        VaccinationImportSelectionItem(token: CBORWebToken.mockVaccinationCertificate.extended()),
        TestImportSelectionItem(token: CBORWebToken.mockTestCertificateWithFixedSc.extended())
    ].compactMap { $0 }

    func confirm() {
        importCertificatesExpectation.fulfill()
    }

    func cancel() {}
    func toggleSelection() {}
}

private extension CBORWebToken {
    static var mockTestCertificateWithFixedSc: Self {
        let token = Self.mockTestCertificate
        token.hcert.dgc.t?.first?.sc = .init(timeIntervalSinceReferenceDate: 0)
        return token
    }
}
