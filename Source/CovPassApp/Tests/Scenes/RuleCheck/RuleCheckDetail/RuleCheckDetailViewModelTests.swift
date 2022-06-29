//
//  RuleCheckDetailViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import PromiseKit
import XCTest

private enum Constants {
    static let dobTitle = "Geburtsdatum / Date of birth (YYYY-MM-DD)"
    static let testFacilityTitle = "Testzentrum oder -einrichtung / Testing centre or facility"
    static let countryVacctionationTitle = "Land der Impfung / Country vaccinating"
    static let countryRecoveryAndTestTitle = "Land der Testung / Country performing test"
}

class RuleCheckDetailViewModelTests: XCTestCase {
    private var sut: RuleCheckDetailViewModel!
    override func setUpWithError() throws {
        try configureSut(token: .mock())
    }

    override func tearDownWithError() throws {
       sut = nil
    }

    private func configureSut(token: ExtendedCBORWebToken) {
        let (_, resolver) = Promise<Void>.pending()
        sut = .init(
            router: RuleCheckDetailRouter(
                sceneCoordinator: SceneCoordinatorMock()
            ),
            resolvable: resolver,
            result: .init(certificate: token, result: []),
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
        let countryItem =  items.first { title, _, _, _ in
            title == Constants.countryVacctionationTitle
        }
        XCTAssertEqual(countryItem?.1, "Germany")
        XCTAssertEqual(dobItem?.1, "1964-08-12")
    }

    func testItems_recovery() {
        // Given
        let token = CBORWebToken.mockRecoveryCertificate.extended()
        configureSut(token: token)

        // When
        let items = sut.items

        // Then
        let dobItem = items.first { title, _, _, _ in
            title == Constants.dobTitle
        }
        let countryItem =  items.first { title, _, _, _ in
            title == Constants.countryRecoveryAndTestTitle
        }
        XCTAssertEqual(countryItem?.1, "Germany")
        XCTAssertEqual(dobItem?.1, "1990-01-01")
    }

    func testItems_test() throws {
        // Given
        var cborWebToken = CBORWebToken.mockTestCertificate
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
        let countryItem =  items.first { title, _, _, _ in
            title == Constants.countryRecoveryAndTestTitle
        }
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
        let countryItem =  items.first { title, _, _, _ in
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
        let countryItem =  items.first { title, _, _, _ in
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
        let countryItem =  items.first { title, _, _, _ in
            title == Constants.countryRecoveryAndTestTitle
        }
        XCTAssertEqual(countryItem?.1, "Brazil")
    }
}

