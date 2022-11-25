//
//  SelectStateOnboardingViewModelTests.swift
//
//
//  Created by Fatih Karakurt on 14.10.22.
//

import CovPassCommon
@testable import CovPassUI
import PromiseKit
import XCTest

class SelectStateOnboardingViewModelTests: XCTestCase {
    private var promise: Promise<Void>!
    private var sut: SelectStateOnboardingViewModel!
    private var router: SelectStateOnboardingViewRouterMock!

    override func setUpWithError() throws {
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        router = SelectStateOnboardingViewRouterMock()
        sut = .init(resolver: resolver, router: router, userDefaults: MockPersistence(), certificateHolderStatus: CertificateHolderStatusModel(dccCertLogic: DCCCertLogicMock()))
    }

    override func tearDownWithError() throws {
        promise = nil
        router = nil
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

    func testShowFederalStateSelection() throws {
        // When
        sut.showFederalStateSelection().cauterize()

        // Then
        wait(for: [router.showFederalStateSelectionExpectation], timeout: 1)
    }
}
