//
//  ReissueStart.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class ReissueStartViewModelTests: XCTestCase {
    private var sut: ReissueStartViewModel!
    private var mockRouter: ReissueStartRouterMock!
    private var promise: Promise<Void>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        configureSut()
    }

    private func configureSut(
        tokens: [ExtendedCBORWebToken] = [CBORWebToken.mockVaccinationCertificate.extended()],
        context: ReissueContext = .boosterRenewal
    ) {
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        mockRouter = ReissueStartRouterMock()
        sut = ReissueStartViewModel(
            router: mockRouter,
            resolver: resolver,
            tokens: tokens,
            context: context
        )
    }

    override func tearDownWithError() throws {
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

    func testCertItem_booster() {
        // Given
        let token1 = CBORWebToken.mockRecoveryCertificate.recoveryTestDate(.distantFuture).extended(vaccinationQRCodeData: "1")
        let token2 = CBORWebToken.mockVaccinationCertificate.doseNumber(1).extended(vaccinationQRCodeData: "1")
        configureSut(tokens: [token1, token2])

        // When
        let certItem = sut.certItem

        // Then
        XCTAssertEqual(certItem.activeLabel.text, "Vaccinated on Jan 1, 2021")
    }

    func testCertItem_expiry_extension() {
        // Given
        let token1 = CBORWebToken.mockRecoveryCertificate.recoveryTestDate(.distantFuture).extended(vaccinationQRCodeData: "1")
        let token2 = CBORWebToken.mockVaccinationCertificate.doseNumber(1).extended(vaccinationQRCodeData: "1")
        configureSut(tokens: [token1, token2], context: .certificateExtension)

        // When
        let certItem = sut.certItem

        // Then
        XCTAssertEqual(certItem.activeLabel.text, "Maximum valid until May 1, 2022")
    }
}
