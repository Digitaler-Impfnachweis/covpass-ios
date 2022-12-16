//
//  DifferentPersonViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import PromiseKit
import XCTest

class DifferentPersonViewModelTests: XCTestCase {
    private var delegate: ViewModelDelegateMock!
    private var sut: DifferentPersonViewModel!

    override func setUpWithError() throws {
        let (_, resolver) = Promise<ValidatorDetailSceneResult>.pending()
        let token1 = CBORWebToken.mockVaccinationCertificate.extended()
        let token2 = CBORWebToken.mockTestCertificate.extended()
        let tokens = [token1, token2]
        delegate = .init()
        sut = .init(
            tokens: tokens,
            resolver: resolver,
            countdownTimerModel: .init(dismissAfterSeconds: 0, countdownDuration: 0)
        )
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        delegate = nil
        sut = nil
    }

    func testInit() {
        // Given
        let expectation = XCTestExpectation()
        delegate.didUpdate = {
            expectation.fulfill()
        }
        sut.startCountdown()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(sut.countdownTimerModel.shouldDismiss)
    }
}
