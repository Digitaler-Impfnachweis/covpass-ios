//
//  RuleCheckViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class RuleCheckViewModelTests: XCTestCase {
    private var certLogic: DCCCertLogicMock!
    private var delegate: MockViewModelDelegate!
    private var repository: VaccinationRepositoryMock!
    private var router: RuleCheckRouterMock!
    private var sut: RuleCheckViewModel!

    override func setUpWithError() throws {
        certLogic = DCCCertLogicMock()
        certLogic.countries = [.init("AL"), .init("IL"), .init("RO"), .init("PA")]
        delegate = MockViewModelDelegate()
        repository = VaccinationRepositoryMock()
        repository.certificates = try [.mock(), .mock(), .mock()]
        router = RuleCheckRouterMock()
        sut = RuleCheckViewModel(
            router: router,
            resolvable: nil,
            repository: repository,
            certLogic: certLogic
        )
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        delegate = nil
        repository = nil
        router = nil
        sut = nil
    }

    func testShowCountrySelection() {
        // Given
        let de2Country = Country("DE2")
        let expectedCountries = certLogic.countries + [de2Country]
        let expectedCountry = "EXPECTED-COUNTRY"
        let expectedCountryToReturn = "COUNTRY-TO-RETURN"
        sut.country = expectedCountry
        router.countryToReturn = expectedCountryToReturn

        // When
        sut.showCountrySelection()

        // Then
        wait(for: [
            router.showCountrySelectionExpectation,
            delegate.viewModelDidUpdateExpectation
        ], timeout: 3)

        XCTAssertEqual(router.receivedCountry, expectedCountry)
        XCTAssertEqual(router.receivedCountries, expectedCountries)
        XCTAssertEqual(sut.country, expectedCountryToReturn)
        XCTAssertTrue(sut.isLoading)
    }

    func testUpdateRules() {
        // When
        sut.updateRules()

        // Then
        wait(for: [
            delegate.viewModelDidUpdateExpectation,
            repository.getCertificateListExpectation
        ], timeout: 3)

        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.validationViewModels.count, 1)
    }
}
