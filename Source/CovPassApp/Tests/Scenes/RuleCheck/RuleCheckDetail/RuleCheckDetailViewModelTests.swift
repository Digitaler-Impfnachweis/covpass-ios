//
//  RuleCheckDetailViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
@testable import CovPassApp
import CovPassCommon
import PromiseKit
import XCTest

private enum Constants {
    static let dobTitle = "Geburtsdatum / Date of birth (YYYY-MM-DD)"
    static let testFacilityTitle = "Testzentrum oder -einrichtung / Testing centre or facility"
    static let countryVacctionationTitle = "Land der Impfung / Country vaccinating"
    static let countryRecoveryAndTestTitle = "Land der Testung / Country performing test"
    static let fullnameTransliteratedTitle = "Standardisierter Name, Vorname / Standardized name, first name"
    static let technicalExpiryTitle = "Technical expiry date / Technical expiry date"
}

class RuleCheckDetailViewModelTests: XCTestCase {
    private var sut: RuleCheckDetailViewModel!
    private var result: [ValidationResult] = []

    override func setUpWithError() throws {
        try configureSut(token: .mock())
    }

    override func tearDownWithError() throws {
        result = []
        sut = nil
    }

    private func configureSut(token: ExtendedCBORWebToken, result: [ValidationResult] = []) {
        let (_, resolver) = Promise<Void>.pending()
        self.result = result
        sut = .init(
            router: RuleCheckDetailRouter(
                sceneCoordinator: SceneCoordinatorMock()
            ),
            resolvable: resolver,
            result: .init(certificate: token, result: result),
            country: "IS",
            date: Date(timeIntervalSinceReferenceDate: 0)
        )
    }

    func testItems_vaccination() {
        // When
        let items = sut.items

        // Then
        let dobItem = items.first { title, _, _, _ in
            title == Constants.dobTitle
        }
        let countryItem = items.first { title, _, _, _ in
            title == Constants.countryVacctionationTitle
        }
        let fullnameTransliteratedItem = items.first { title, _, _, _ in
            title == Constants.fullnameTransliteratedTitle
        }
        let technicalExpiryDateItem = items.first { title, _, _, _ in
            title == Constants.technicalExpiryTitle
        }
        XCTAssertEqual(fullnameTransliteratedItem?.1, "SCHMITT<MUSTERMANN, ERIKA<DOERTE")
        XCTAssertEqual(
            technicalExpiryDateItem?.1,
            "Valid until Jun 23, 2026 at 8:25 PM\nYou will be notified in the app if you can renew the certificate."
        )
        XCTAssertEqual(countryItem?.1, "Germany")
        XCTAssertEqual(dobItem?.1, "1964-08-12")
    }

    func testItems_recovery() {
        // Given
        var cborToken = CBORWebToken.mockRecoveryCertificate
        cborToken.exp = .init(timeIntervalSinceReferenceDate: 0)
        let token = cborToken.extended()
        configureSut(token: token)

        // When
        let items = sut.items

        // Then
        let dobItem = items.first { title, _, _, _ in
            title == Constants.dobTitle
        }
        let countryItem = items.first { title, _, _, _ in
            title == Constants.countryRecoveryAndTestTitle
        }
        let fullnameTransliteratedItem = items.first { title, _, _, _ in
            title == Constants.fullnameTransliteratedTitle
        }
        let technicalExpiryDateItem = items.first { title, _, _, _ in
            title == Constants.technicalExpiryTitle
        }
        XCTAssertEqual(fullnameTransliteratedItem?.1, "JOHN, DOE")
        XCTAssertEqual(
            technicalExpiryDateItem?.1,
            "Valid until Jan 1, 2001 at 1:00 AM\nYou will be notified in the app if you can renew the certificate."
        )
        XCTAssertEqual(countryItem?.1, "Germany")
        XCTAssertEqual(dobItem?.1, "1990-01-01")
    }

    func testItems_test() throws {
        // Given
        var cborWebToken = CBORWebToken.mockTestCertificate
        cborWebToken.exp = .init(timeIntervalSinceReferenceDate: 0)
        let test = try XCTUnwrap(cborWebToken.hcert.dgc.t?.first)
        test.tc = nil
        cborWebToken.hcert.dgc.t = [test]
        configureSut(token: cborWebToken.extended())

        // When
        let items = sut.items

        // Then
        let dobItem = items.first { title, _, _, _ in
            title == Constants.dobTitle
        }
        let testFacilityItem = items.first { title, _, _, _ in
            title == Constants.testFacilityTitle
        }
        let countryItem = items.first { title, _, _, _ in
            title == Constants.countryRecoveryAndTestTitle
        }
        let fullnameTransliteratedItem = items.first { title, _, _, _ in
            title == Constants.fullnameTransliteratedTitle
        }
        let technicalExpiryDateItem = items.first { title, _, _, _ in
            title == Constants.technicalExpiryTitle
        }
        XCTAssertEqual(fullnameTransliteratedItem?.1, "JOHN, DOE")
        XCTAssertEqual(
            technicalExpiryDateItem?.1,
            "Valid until Jan 1, 2001 at 1:00 AM\nYou will be notified in the app if you can renew the certificate."
        )
        XCTAssertEqual(countryItem?.1, "Germany")
        XCTAssertEqual(dobItem?.1, "1990-01-01")
        XCTAssertEqual(testFacilityItem?.1, "")
    }

    func testItems_vaccination_co_not_germany() {
        // Given
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        cborWebToken.hcert.dgc.v?.first?.co = "IL"
        configureSut(token: cborWebToken.extended())

        // When
        let items = sut.items

        // Then
        let countryItem = items.first { title, _, _, _ in
            title == Constants.countryVacctionationTitle
        }
        XCTAssertEqual(countryItem?.1, "Israel")
    }

    func testItems_test_co_not_germany() {
        // Given
        let cborWebToken = CBORWebToken.mockTestCertificate
        cborWebToken.hcert.dgc.t?.first?.co = "IS"
        configureSut(token: cborWebToken.extended())

        // When
        let items = sut.items

        // Then
        let countryItem = items.first { title, _, _, _ in
            title == Constants.countryRecoveryAndTestTitle
        }
        XCTAssertEqual(countryItem?.1, "Iceland")
    }

    func testItems_recovery_co_not_germany() {
        // Given
        let cborWebToken = CBORWebToken.mockRecoveryCertificate
        cborWebToken.hcert.dgc.r?.first?.co = "BR"
        configureSut(token: cborWebToken.extended())

        // When
        let items = sut.items

        // Then
        let countryItem = items.first { title, _, _, _ in
            title == Constants.countryRecoveryAndTestTitle
        }
        XCTAssertEqual(countryItem?.1, "Brazil")
    }

    func test_resultSubtitle_resultEmpty() throws {
        // GIVEN
        configureSut(token: try .mock(), result: [])
        // WHEN
        let resultSubtitle = sut.resultSubtitle
        // THEN
        XCTAssertEqual(resultSubtitle, "For Iceland on Jan 1, 2001 at 1:00 AM\n\nUnfortunately, an automatic check is not possible, as no entry rules are stored for this country. Please consult the website of the Federal Foreign Office for more information.")
    }

    func test_resultSubtitle_oneResultPassed() throws {
        // GIVEN
        let rule: Rule = .init()
        let result: Array<ValidationResult>.ArrayLiteralElement = .init(rule: rule, result: .passed)
        configureSut(token: try .mock(), result: [result])
        // WHEN
        let resultSubtitle = sut.resultSubtitle
        // THEN
        XCTAssertEqual(resultSubtitle, "For Iceland on Jan 1, 2001 at 1:00 AM\n\n1 rule of the destination country was successfully checked.")
    }

    func test_resultSubtitle_twoResultPassed() throws {
        // GIVEN
        let rule: Rule = .init()
        let result: Array<ValidationResult>.ArrayLiteralElement = .init(rule: rule, result: .passed)
        configureSut(token: try .mock(), result: [result, result])
        // WHEN
        let resultSubtitle = sut.resultSubtitle
        // THEN
        XCTAssertEqual(resultSubtitle, "For Iceland on Jan 1, 2001 at 1:00 AM\n\n2 rules of the destination country were successfully checked.")
    }
}
