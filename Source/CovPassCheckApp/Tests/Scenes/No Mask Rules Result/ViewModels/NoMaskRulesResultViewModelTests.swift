//
//  NoMaskRulesResultViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassUI
import PromiseKit
import XCTest

final class NoMaskRulesResultViewModelTests: XCTestCase {
    var countdownTimerModel: CountdownTimerModel!
    var delegate: ViewModelDelegateMock!
    var promise: Promise<Void>!
    var resolver: Resolver<Void>!
    var router: NoMaskRulesResultRouterMock!
    var sut: NoMaskRulesResultViewModel!

    override func setUpWithError() throws {
        let (promise, resolver) = Promise<Void>.pending()
        countdownTimerModel = .init(dismissAfterSeconds: 100, countdownDuration: 0)
        self.promise = promise
        self.resolver = resolver
        router = .init()
        delegate = .init()
        configureSut()
    }

    private func configureSut() {
        sut = .init(
            countdownTimerModel: countdownTimerModel,
            federalStateCode: "DE_NW",
            resolver: resolver,
            router: router
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
        promise.done { expectation.fulfill() }.cauterize()

        // When
        sut.cancel()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testRescan() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { expectation.fulfill() }.cauterize()

        // When
        sut.rescan()

        // Then
        wait(for: [expectation, router.rescanExpectation], timeout: 1)
    }

    func testCountdownTimerModel() {
        // Given
        let didUpdateExpectation = XCTestExpectation(description: "didUpdateExpectation")
        let doneExpectation = XCTestExpectation(description: "doneExpectation")
        countdownTimerModel = .init(dismissAfterSeconds: 1.5, countdownDuration: 1)
        delegate.didUpdate = { didUpdateExpectation.fulfill() }
        promise.done { doneExpectation.fulfill() }.cauterize()

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
        
        // When
        let subtitle = sut.subtitle

        // Then
        XCTAssertEqual(subtitle, "In Northrhine-Westphalia")
    }
}
