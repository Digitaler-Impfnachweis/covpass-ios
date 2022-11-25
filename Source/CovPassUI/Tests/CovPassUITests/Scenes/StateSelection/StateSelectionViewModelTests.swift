//
//  StateSelectionViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
@testable import CovPassUI
import PromiseKit
import XCTest

class StateSelectionViewModelTests: XCTestCase {
    private var sut: StateSelectionViewModel!
    private var persistence: UserDefaultsPersistence!
    private var promise: Promise<Void>!

    override func setUp() {
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        persistence = UserDefaultsPersistence()
        sut = .init(persistence: persistence, resolver: resolver)
    }

    override func tearDown() {
        promise = nil
        persistence = nil
        sut = nil
    }

    func testStatesIsNotEmpty() {
        // WHEN
        let states = sut.states
        // THEN
        XCTAssertEqual(states.isEmpty, false)
    }

    func testStatesOrder() {
        // WHEN
        let states = sut.states
        // THEN
        XCTAssertEqual(states.first?.code, "BB")
        XCTAssertEqual(states.last?.code, "TH")
    }

    func testStatesCount() {
        // WHEN
        let states = sut.states
        // THEN
        XCTAssertEqual(states.count, 16)
    }

    func testPageTitle() {
        // WHEN
        let pageTitle = sut.pageTitle
        // THEN
        XCTAssertEqual(pageTitle, "infschg_module_choose_federal_state_title")
    }

    func testChooseSL() {
        // GIVEN
        persistence.stateSelection = ""
        // WHEN
        sut.choose(state: "SL")
        // THEN
        XCTAssertEqual(persistence.stateSelection, "SL")
    }

    func testChooseRandom() {
        // GIVEN
        persistence.stateSelection = ""
        // WHEN
        sut.choose(state: "Foo")
        // THEN
        XCTAssertEqual(persistence.stateSelection, "Foo")
    }

    func testChooseFulfill() {
        // GIVEN
        let expectation = XCTestExpectation(description: "Wait to fullfill resolver")
        promise
            .done { _ in
                expectation.fulfill()
            }.catch { _ in
                XCTFail("Should not fail")
            }
        // WHEN
        sut.choose(state: "Foo")

        // THEN
        wait(for: [expectation], timeout: 1.0)
    }
}
