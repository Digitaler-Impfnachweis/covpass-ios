//
//  MaskRequiredResultViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import PromiseKit
import XCTest

final class MaskRequiredResultViewModelTests: XCTestCase {
    var promise: Promise<Void>!
    var router: MaskRequiredResultRouterMock!
    var sut: MaskRequiredResultViewModel!

    override func setUpWithError() throws {
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        router = .init()
        sut = .init(
            resolver: resolver,
            router: router
        )
    }

    override func tearDownWithError() throws {
        promise = nil
        router = nil
        sut = nil
    }

    func testClose() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _ in
            expectation.fulfill()
        }.cauterize()

        // When
        sut.close()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testRescan() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _ in
            expectation.fulfill()
        }.cauterize()

        // When
        sut.rescan()

        // Then
        wait(for: [expectation, router.rescanExpectation], timeout: 1)
    }
}
