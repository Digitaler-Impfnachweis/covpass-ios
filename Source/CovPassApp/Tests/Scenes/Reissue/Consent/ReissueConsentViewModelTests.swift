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
                                      decoder: JSONDecoder(),
                                      locale: .current)
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
        XCTAssertFalse(sut.isLoading)
    }

    func testProcessAgree_error_unexpected_error_type() throws {
        // Given
        let expectedFaqURL = try XCTUnwrap(
            URL(string: "https://www.digitaler-impfnachweis-app.de/en/faq#fragen-zur-covpass-app")
        )
        let expectedTitle = "Reissue failed"
        let expectedMessage = "Unfortunately, there was a problem reissuing your certificate. Please check your internet connection. Note that the certificate can be reissued a maximum of three times a year. For more information on the error code below please contact our hotline at 0800–4747–001 or support@covpass-app.de.\n\nError code: R000"

        let error = NSError(domain: "", code: 0)
        reissueRepository.error = error

        // When
        sut.processAgree()

        // Then
        wait(for: [mockRouter.showErrorExpectation], timeout: 1)
        XCTAssertEqual(mockRouter.receivedErrorFaqURL, expectedFaqURL)
        XCTAssertEqual(mockRouter.receivedErrorTitle, expectedTitle)
        XCTAssertEqual(mockRouter.receivedErrorMessage, expectedMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testProcessAgree_CertificateReissueRepositoryError() throws {
        // Given
        let error = CertificateReissueRepositoryError("ERRORCODE XYZ", message: nil)
        reissueRepository.error = error

        // When
        sut.processAgree()

        // Then
        wait(for: [mockRouter.showErrorExpectation], timeout: 1)
        let message = try XCTUnwrap(mockRouter.receivedErrorMessage)
        XCTAssertTrue(message.contains("ERRORCODE XYZ"))
    }

    func testProcessAgree_error_german_locale() throws {
        // Given
        let expectedFaqURL = try XCTUnwrap(
            URL(string: "https://www.digitaler-impfnachweis-app.de/faq/#fragen-zur-covpass-app")
        )
        let error = CertificateReissueRepositoryFallbackError()
        let (_, resolver) = Promise<Void>.pending()
        reissueRepository.error = error
        sut = .init(
            router: mockRouter,
            resolver: resolver,
            tokens: [],
            reissueRepository: reissueRepository,
            vaccinationRepository: VaccinationRepositoryMock(),
            decoder: JSONDecoder(),
            locale: Locale(identifier: "DE")
        )

        // When
        sut.processAgree()

        // Then
        wait(for: [mockRouter.showErrorExpectation], timeout: 1)
        XCTAssertEqual(mockRouter.receivedErrorFaqURL, expectedFaqURL)
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

    func testIsLoading_default() {
        // When
        let isLoading = sut.isLoading

        // Then
        XCTAssertFalse(isLoading)
    }

    func testIsLoading_true() {
        // Given
        reissueRepository.responseDelay = 1
        sut.processAgree()

        // When
        let isLoading = sut.isLoading

        // Then
        XCTAssertTrue(isLoading)
    }
}
