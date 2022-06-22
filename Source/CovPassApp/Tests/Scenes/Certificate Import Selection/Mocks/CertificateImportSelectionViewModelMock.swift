//
//  CertificateImportSelectionViewModelMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

final class CertificateImportSelectionViewModelMock: CertificateImportSelectionViewModelProtocol {
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
        VaccinationImportSelectionItem(name: .name1(), vaccination: .mock()),
        VaccinationImportSelectionItem(name: .name2(), vaccination: .mock()),
        VaccinationImportSelectionItem(name: .name1(), vaccination: .mock()),
        VaccinationImportSelectionItem(name: .name1(), vaccination: .mock()),
        VaccinationImportSelectionItem(name: .name1(), vaccination: .mock()),
        VaccinationImportSelectionItem(name: .name1(), vaccination: .mock()),
        VaccinationImportSelectionItem(name: .name3(), vaccination: .mock())
    ]

    func confirm() {
        importCertificatesExpectation.fulfill()
    }

    func cancel() {}
    func toggleSelection() {}
}
