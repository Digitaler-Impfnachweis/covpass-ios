//
//  ReissueStart.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassUI
import XCTest
import PromiseKit
import CovPassCommon

class ReissueStartViewModelTests: XCTestCase {
    
    private var sut: ReissueStartViewModel!
    private var mockRouter: ReissueStartRouterMock!
    private var token: ExtendedCBORWebToken!
    private var promise: Promise<Void>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        mockRouter = ReissueStartRouterMock()
        token = CBORWebToken.mockVaccinationCertificate.extended()
        sut = ReissueStartViewModel(router: mockRouter,
                                    resolver: resolver,
                                    tokens: [token],
                                    context: .boosterRenewal)
    }
    
    override func tearDownWithError() throws {
        token = nil
        mockRouter = nil
        sut = nil
        promise = nil
    }
    
    func testShowNext() {
        // WHEN
        sut.processStart()
        // THEN
        wait(for: [mockRouter.showNextExpectation], timeout: 0.1)
    }
    
    func testProcessLater() {
        // GIVEN
        let expectation = XCTestExpectation()
        // WHEN
        sut.processLater()
        // THEN
        promise.done { _ in
            expectation.fulfill()
        }
        .cauterize()
        wait(for: [expectation], timeout: 1)
    }
}
