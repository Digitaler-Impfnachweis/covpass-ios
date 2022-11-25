//
//  CountrySelectionViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import PromiseKit
import XCTest

class CountrySelectionViewModelTests: XCTestCase {
    private var sut: CountrySelectionViewModel!

    override func setUpWithError() throws {
        let (_, resolver) = Promise<String>.pending()
        sut = CountrySelectionViewModel(router: CountrySelectionRouterMock(),
                                        resolvable: resolver,
                                        countries: CountrySelectionMock.countries,
                                        country: "DE")
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testOrder() {
        // WHEN
        let indexDE = sut.countries.firstIndex(of: Country("DE"))
        let indexDE2 = sut.countries.firstIndex(of: Country("DE2"))

        // THEN
        XCTAssertEqual(indexDE2, 13)
        XCTAssertEqual(indexDE, 14)
    }
}
