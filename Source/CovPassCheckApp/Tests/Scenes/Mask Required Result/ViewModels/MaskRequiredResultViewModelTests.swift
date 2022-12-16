//
//  MaskRequiredResultViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

final class MaskRequiredResultViewModelTests: XCTestCase {
    var countdownTimerModel: CountdownTimerModel!
    var delegate: ViewModelDelegateMock!
    var promise: Promise<ValidatorDetailSceneResult>!
    var resolver: Resolver<ValidatorDetailSceneResult>!
    var router: MaskRequiredResultRouterMock!
    var sut: MaskRequiredResultViewModel!

    override func setUpWithError() throws {
        let (promise, resolver) = Promise<ValidatorDetailSceneResult>.pending()
        countdownTimerModel = .init(dismissAfterSeconds: 100, countdownDuration: 0)
        self.promise = promise
        self.resolver = resolver
        router = .init()
        delegate = .init()
        configureSut()
    }

    private func configureSut(
        reasonType: MaskRequiredReasonType = .functional,
        secondCertificateHintHidden: Bool = false
    ) {
        var persistence = MockPersistence()
        persistence.revocationExpertMode = true
        persistence.stateSelection = "NW"
        sut = .init(
            token: CBORWebToken.mockVaccinationCertificate.extended(),
            countdownTimerModel: countdownTimerModel,
            resolver: resolver,
            router: router,
            reasonType: reasonType,
            secondCertificateHintHidden: secondCertificateHintHidden,
            persistence: persistence,
            certificateHolderStatus: CertificateHolderStatusModelMock(),
            revocationKeyFilename: ""
        )
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        countdownTimerModel = nil
        delegate = nil
        promise = nil
        resolver = nil
        router = nil
        sut = nil
    }

    func testCancel() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _ in expectation.fulfill() }.cauterize()

        // When
        sut.cancel()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testRescan() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _
            in expectation.fulfill()
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
        promise.done { _ in doneExpectation.fulfill() }.cauterize()

        // When
        configureSut()
        sut.startCountdown()

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
        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "in Northrhine-Westphalia*")
    }

    func testReasonViewModels_reason_type_functional() {
        // When
        let viewModels = sut.reasonViewModels

        // Then
        if viewModels.count == 3 {
            XCTAssertTrue(viewModels[0] is MaskRequiredValidityDateReasonViewModel)
            XCTAssertTrue(viewModels[1] is MaskRequiredWrongCertificateReasonViewModel)
            XCTAssertTrue(viewModels[2] is MaskRequiredIncompleteSeriesReasonViewModel)
        } else {
            XCTFail("Must have 3 reason view models.")
        }
    }

    func testReasonViewModels_reason_type_technical() {
        // Given
        configureSut(reasonType: .technical)

        // When
        let viewModels = sut.reasonViewModels

        // Then
        if viewModels.count == 2 {
            XCTAssertTrue(viewModels[0] is MaskRequiredInvalidSignatureReasonViewModel)
            XCTAssertTrue(viewModels[1] is MaskRequiredQRCodeReasonViewModel)
        } else {
            XCTFail("Must have 2 reason view models.")
        }
    }

    func testSecondCertificateHintHidden_false() {
        // When
        let isHidden = sut.secondCertificateHintHidden

        // Then
        XCTAssertFalse(isHidden)
    }

    func testSecondCertificateHintHidden_true() {
        // Given
        configureSut(secondCertificateHintHidden: true)

        // When
        let isHidden = sut.secondCertificateHintHidden

        // Then
        XCTAssertTrue(isHidden)
    }

    func testScanSecondCertificate() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _ in
            expectation.fulfill()
        }.cauterize()

        // When
        sut.scanSecondCertificate()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testAccessibilityCloseButton() {
        // WHEN
        let closeButtonAccessibilityText = sut.closeButtonAccessibilityText
        // THEN
        XCTAssertEqual(closeButtonAccessibilityText, "Close")
    }
}
