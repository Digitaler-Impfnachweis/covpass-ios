//
//  MaskOptionalResultViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

final class MaskOptionalResultViewModelTests: XCTestCase {
    var countdownTimerModel: CountdownTimerModel!
    var delegate: ViewModelDelegateMock!
    var persistence: MockPersistence!
    var promise: Promise<ValidatorDetailSceneResult>!
    var resolver: Resolver<ValidatorDetailSceneResult>!
    var router: MaskOptionalResultRouterMock!
    var sut: MaskOptionalResultViewModel!

    override func setUpWithError() throws {
        let (promise, resolver) = Promise<ValidatorDetailSceneResult>.pending()
        countdownTimerModel = .init(dismissAfterSeconds: 100, countdownDuration: 0)
        self.promise = promise
        self.resolver = resolver
        router = .init()
        delegate = .init()
        persistence = .init()
        configureSut()
    }

    private func configureSut(reasonType: MaskRequiredReasonType = .functional) {
        sut = .init(
            token: CBORWebToken.mockVaccinationCertificate.extended(),
            countdownTimerModel: countdownTimerModel,
            resolver: resolver,
            router: router,
            persistence: persistence,
            certificateHolderStatus: CertificateHolderStatusModelMock(),
            revocationKeyFilename: "ABC"
        )
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        countdownTimerModel = nil
        delegate = nil
        persistence = nil
        promise = nil
        resolver = nil
        router = nil
        sut = nil
    }

    func testCancel() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { result in expectation.fulfill() }.cauterize()

        // When
        sut.cancel()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testRescan() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { result in
            expectation.fulfill()
        }.cauterize()

        // When
        sut.rescan()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testCountdownTimerModel() {
        // Given
        let didUpdateExpectation = XCTestExpectation(description: "didUpdateExpectation")
        let doneExpectation = XCTestExpectation(description: "doneExpectation")
        countdownTimerModel = .init(dismissAfterSeconds: 1.5, countdownDuration: 1)
        delegate.didUpdate = { didUpdateExpectation.fulfill() }
        promise.done { result in doneExpectation.fulfill() }.cauterize()

        // When
        configureSut()

        // Then
        wait(for: [didUpdateExpectation, doneExpectation], timeout: 3, enforceOrder: true)
    }

    func testIsCancellable() {
        // When
        let isCancellable = sut.isCancellable()

        // Then
        XCTAssertTrue(isCancellable)
    }

    func testSubtitle() {
        // Given
        persistence.stateSelection = "NW"
        configureSut()

        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "In Northrhine-Westphalia")
    }

    func testRevoke() {
        // When
        sut.revoke(0)

        // Then
        wait(for: [router.revokeExpectation], timeout: 1)
        XCTAssertEqual(router.receivedRevocationKeyFilename, "ABC")
    }

    func testRevocationInfoHidden_expertMode_true() {
        // Given
        persistence.revocationExpertMode = true
        configureSut()

        // When
        let isHidden = sut.revocationInfoHidden

        // Then
        XCTAssertFalse(isHidden)
    }

    func testRevocationInfoHidden_expertMode_false() {
        // Given
        persistence.revocationExpertMode = false
        configureSut()

        // When
        let isHidden = sut.revocationInfoHidden

        // Then
        XCTAssertTrue(isHidden)
    }
    
    func testAccessibilityCloseButton() {
        // WHEN
        let closeButtonAccessibilityText = sut.closeButtonAccessibilityText
        // THEN
        XCTAssertEqual(closeButtonAccessibilityText, "Close")
    }
}
