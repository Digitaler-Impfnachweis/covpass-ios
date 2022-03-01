//
//  ReissueConsentViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassUI
import XCTest
import PromiseKit
import CovPassCommon

class ReissueConsentViewModelTests: XCTestCase {
    
    private var sut: ReissueConsentViewModel!
    private var mockRouter: ReissueConsentRouterMock!
    private var token: ExtendedCBORWebToken!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        mockRouter = ReissueConsentRouterMock()
        token = CBORWebToken.mockVaccinationCertificate.extended()
        sut = ReissueConsentViewModel(router: mockRouter,
                                      resolver: resolver,
                                      tokens: [token],
                                      reissueRepository: CertificateReissueRepositoryMock(),
                                      vaccinationRepository: VaccinationRepositoryMock(),
                                      decoder: JSONDecoder())
    }
    
    override func tearDownWithError() throws {
        token = nil
        mockRouter = nil
        sut = nil
    }
    
    func testProcessAgree() {
        // WHEN
        sut.processAgree()
        // THEN
        wait(for: [mockRouter.showNextExpectation], timeout: 0.1)
    }
    
    func testProcessDisagree() {
        // WHEN
        sut.processDisagree()
        // THEN
        wait(for: [mockRouter.cancelExpectation], timeout: 0.1)
    }
    
    func testProcessPrivacyStatement() {
        // WHEN
        sut.processPrivacyStatement()
        // THEN
        wait(for: [mockRouter.routeToPrivacyExpectation], timeout: 0.1)
    }
}
