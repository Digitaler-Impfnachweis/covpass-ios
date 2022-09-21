//
//  NewRegulationsAnnouncementViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import PromiseKit
import XCTest

class NewRegulationsAnnouncementViewModelTests: XCTestCase {
    private var promise: Promise<Void>!
    private var sut: NewRegulationsAnnouncementViewModel!
    override func setUpWithError() throws {
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        sut = .init(resolver: resolver)
    }

    override func tearDownWithError() throws {
        promise = nil
        sut = nil
    }

    func testClose() throws {
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
}
