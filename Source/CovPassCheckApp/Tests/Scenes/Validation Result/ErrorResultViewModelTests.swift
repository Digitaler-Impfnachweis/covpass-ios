//
//  ErrorResultViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import PromiseKit
import XCTest

class ErrorResultViewModelTests: XCTestCase {
    private var sut: ErrorResultViewModel!

    override func setUpWithError() throws {
        let (_, resolver) = Promise<ExtendedCBORWebToken>.pending()

        sut = .init(
            resolvable: resolver,
            router: ValidationResultRouterMock(),
            repository: VaccinationRepositoryMock(),
            error: NSError(domain: "TEST", code: 0),
            _2GContext: false,
            userDefaults: MockPersistence(),
            revocationKeyFilename: ""
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testCountdownTimerModel() {
        // When
        let countdownTimerModel = sut.countdownTimerModel

        // Then
        XCTAssertNil(countdownTimerModel)
    }
}
