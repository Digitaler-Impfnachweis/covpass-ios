//
//  ResultViewViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
@testable import CovPassUI
import PromiseKit
import UIKit
import XCTest

class ResultViewViewModelTests: XCTestCase {
    private var promise: Promise<Void>!
    private var resolver: Resolver<Void>!
    private var router: ResultViewRouterMock!
    private var sut: ResultViewViewModel!

    override func setUpWithError() throws {
        let (promise, resolver) = Promise<Void>.pending()
        let image = UIImage.close
        self.promise = promise
        self.resolver = resolver
        router = .init()
        let token = ExtendedCBORWebToken(vaccinationCertificate: CBORWebToken.mockVaccinationCertificate,
                                         vaccinationQRCodeData: "TEST")
        sut = .init(
            image: image,
            title: "TITLE",
            description: "DESCRIPTION",
            buttonTitle: "BUTTONTITLE",
            shareButtonTitle: "SHAREBUTTONTITLE",
            resolver: resolver,
            router: router,
            certificate: token
        )
    }

    override func tearDownWithError() throws {
        router = nil
        resolver = nil
        sut = nil
    }

    func testTitle() {
        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "TITLE")
    }

    func testDescription() {
        // When
        let description = sut.description

        // Then
        XCTAssertEqual(description, "DESCRIPTION")
    }

    func testButtonTitle() {
        // When
        let buttonTitle = sut.buttonTitle

        // Then
        XCTAssertEqual(buttonTitle, "BUTTONTITLE")
    }

    func testShareButtonTitle() {
        // When
        let buttonTitle = sut.shareButtonTitle

        // Then
        XCTAssertEqual(buttonTitle, "SHAREBUTTONTITLE")
    }

    func testImage() {
        // When
        let image = sut.image

        // Then
        XCTAssertEqual(image, UIImage.close)
    }

    func testSubmitTapped() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _ in
            expectation.fulfill()
        }.cauterize()

        // When
        sut.submitTapped()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testSharePDFTapped() {
        // When
        sut.shareAsPdf()
        // Then
        wait(for: [router.showPdfExpectation], timeout: 1)
    }
}
