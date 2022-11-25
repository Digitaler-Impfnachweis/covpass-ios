//
//  CountdownTimerModelTests.swift
//
//
//  Created by Thomas Kuleßa on 26.07.22.
//

@testable import CovPassUI
import XCTest

class CountdownTimerModelTests: XCTestCase {
    private var sut: CountdownTimerModel!

    override func setUpWithError() throws {
        sut = .init(
            dismissAfterSeconds: 1,
            countdownDuration: 1
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testCounterInfo_default() {
        // When
        let counterInfo = sut.counterInfo

        // Then
        XCTAssertTrue(counterInfo.isEmpty)
    }

    func testHideCountdown_default() {
        // When
        let hideCountdown = sut.hideCountdown

        // Then
        XCTAssertTrue(hideCountdown)
    }

    func testShouldDismiss_default() {
        // When
        let shouldDismiss = sut.shouldDismiss

        // Then
        XCTAssertFalse(shouldDismiss)
    }

    func testShouldOnUpdate_default() {
        // When
        let onUpdate = sut.onUpdate

        // Then
        XCTAssertNil(onUpdate)
    }

    func testStart_finish_immediately() {
        // Given
        sut = .init(dismissAfterSeconds: 0, countdownDuration: 0)
        let expectation = XCTestExpectation()
        sut.onUpdate = { _ in expectation.fulfill() }

        // When
        sut.start()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(sut.shouldDismiss)
    }

    func testStart_finish_after_2_seconds() {
        // Given
        sut = .init(dismissAfterSeconds: 2, countdownDuration: 0)
        let expectation = XCTestExpectation()
        var afterUpdate: TimeInterval?
        sut.onUpdate = { _ in
            afterUpdate = Date().timeIntervalSinceReferenceDate
            expectation.fulfill()
        }
        let beforeUpdate = Date().timeIntervalSinceReferenceDate

        // When
        sut.start()

        // Then
        wait(for: [expectation], timeout: 3)
        XCTAssertTrue(sut.shouldDismiss)
        if let afterUpdate = afterUpdate {
            let secondsPassed = afterUpdate - beforeUpdate
            XCTAssertGreaterThan(secondsPassed, 2)
        } else {
            XCTFail("Must not be nil.")
        }
    }

    func testStart_countdown() {
        // Given
        sut = .init(dismissAfterSeconds: 10, countdownDuration: 10)
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        sut.onUpdate = { _ in
            expectation.fulfill()
        }

        // When
        sut.start()

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertFalse(sut.hideCountdown)
        XCTAssertTrue(sut.counterInfo.contains("result_countdown"))
    }

    func testReset() {
        // Given
        let expectation = XCTestExpectation()
        sut.onUpdate = { _ in
            expectation.fulfill()
        }
        sut.start()
        wait(for: [expectation], timeout: 2)

        // When
        sut.reset()

        // Then
        XCTAssertFalse(sut.shouldDismiss)
        XCTAssertTrue(sut.counterInfo.isEmpty)
        XCTAssertTrue(sut.hideCountdown)
    }
}
