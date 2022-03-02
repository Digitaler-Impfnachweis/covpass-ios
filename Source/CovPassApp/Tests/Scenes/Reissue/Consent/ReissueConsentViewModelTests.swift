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
    private var reissueRepository: CertificateReissueRepositoryMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        mockRouter = ReissueConsentRouterMock()
        token = CBORWebToken.mockVaccinationCertificate.extended()
        reissueRepository = CertificateReissueRepositoryMock()
        sut = ReissueConsentViewModel(router: mockRouter,
                                      resolver: resolver,
                                      tokens: [token],
                                      reissueRepository: reissueRepository,
                                      vaccinationRepository: VaccinationRepositoryMock(),
                                      decoder: JSONDecoder())
    }
    
    override func tearDownWithError() throws {
        token = nil
        mockRouter = nil
        sut = nil
        reissueRepository = nil
    }
    
    func testProcessAgree() {
        // WHEN
        sut.processAgree()
        // THEN
        wait(for: [mockRouter.showNextExpectation], timeout: 0.1)
    }

    func testProcessAgree_error() {
        // Given
        let error = CertificateReissueError.other(NSError(domain: "TEST", code: 0, userInfo: nil))
        reissueRepository.error = error

        // When
        sut.processAgree()

        // Then
        wait(for: [mockRouter.showErrorExpectation], timeout: 1)
        XCTAssertTrue(mockRouter.receivedError is CertificateReissueError)
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
