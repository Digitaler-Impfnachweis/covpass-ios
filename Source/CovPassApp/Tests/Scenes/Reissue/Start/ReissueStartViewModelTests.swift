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
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        mockRouter = ReissueStartRouterMock()
        token = CBORWebToken.mockVaccinationCertificate.extended()
        sut = ReissueStartViewModel(router: mockRouter,
                                    resolver: resolver,
                                    token: token)
    }
    
    override func tearDownWithError() throws {
        token = nil
        mockRouter = nil
        sut = nil
    }
    
    func testShowNext() {
        // WHEN
        sut.processStart()
        // THEN
        wait(for: [mockRouter.showNextExpectation], timeout: 0.1)
    }
    
    func testProcessLater() {
        // WHEN
        sut.processLater()
        // THEN
        wait(for: [mockRouter.cancelExpectation], timeout: 0.1)
    }
}
