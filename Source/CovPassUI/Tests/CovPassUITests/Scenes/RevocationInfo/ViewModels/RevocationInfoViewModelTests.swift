//
//  RevocationInfoViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
@testable import CovPassUI
import PromiseKit
import XCTest

class RevocationInfoViewModelTests: XCTestCase {
    private var delegate: ViewModelDelegateMock!
    private var pdfGenerator: RevocationPDFGeneratorMock!
    private var promise: Promise<Void>!
    private var resolver: Resolver<Void>!
    private var router: RevocationInfoRouterMock!
    private var sut: RevocationInfoViewModel!

    override func setUpWithError() throws {
        let token = ExtendedCBORWebToken(vaccinationCertificate: .mockCertificate,
                                         vaccinationQRCodeData: "")
        let (promise, resolver) = Promise<Void>.pending()
        pdfGenerator = .init()
        router = .init()
        self.promise = promise
        self.resolver = resolver
        sut = .init(
            router: router,
            resolver: resolver,
            pdfGenerator: pdfGenerator,
            fileManager: FileManager.default,
            token: token,
            coseSign1Message: .mock(),
            timestamp: .init(timeIntervalSinceReferenceDate: 0)
        )
        delegate = .init()
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        delegate = nil
        pdfGenerator = nil
        promise = nil
        resolver = nil
        router = nil
        sut = nil
    }

    func testInfoItems() {
        // When
        let items = sut.infoItems

        // Then
        guard items.count >= 5 else {
            XCTFail("Number of items must be a least 6.")
            return
        }
        XCTAssertEqual(items[0].value, "3d90f482a45f0c9f29345fd9e411cabf9763e6c01591aa68eb64311a35861f90")
        XCTAssertEqual(items[1].value, "lc9a97MWFhs=")
        XCTAssertEqual(items[2].value, "DE")
        XCTAssertEqual(items[3].value, "2002-01-01")
        XCTAssertEqual(items[4].value, "2001-01-01")
    }

    func testCancel() {
        // When
        sut.cancel()

        // Then
        XCTAssertTrue(promise.isFulfilled)
    }

    func testIsGeneratingPDF_default() {
        // When
        let isGeneratingPDF = sut.isGeneratingPDF

        // Then
        XCTAssertFalse(isGeneratingPDF)
    }

    func testCreatePDF_success() {
        // Given
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        delegate.didUpdate = { expectation.fulfill() }
        pdfGenerator.responseDelay = 1

        // When
        sut.createPDF()

        // Then
        XCTAssertTrue(sut.isGeneratingPDF)
        wait(for: [expectation, pdfGenerator.generateExpectation], timeout: 3)
        XCTAssertFalse(sut.isGeneratingPDF)
    }

    func testCreatePDF_error() {
        // Given
        let updateExpectation = XCTestExpectation(description: "updateExpectation")
        let errorExpectation = XCTestExpectation(description: "errorExpectation")
        delegate.didUpdate = { updateExpectation.fulfill() }
        delegate.didFail = { _ in errorExpectation.fulfill() }
        pdfGenerator.error = ApplicationError.general("")

        // When
        sut.createPDF()

        // Then
        wait(for: [updateExpectation, errorExpectation, pdfGenerator.generateExpectation], timeout: 2)
        XCTAssertFalse(sut.isGeneratingPDF)
    }

    func testEnableCreatePDF_germany() {
        // When
        let isEnabled = sut.enableCreatePDF

        // Then
        XCTAssertTrue(isEnabled)
    }

    func testEnableCreatePDF_not_germany() throws {
        // Given
        let token = CBORWebToken.mockCertificate
        let vaccination = try XCTUnwrap(token.hcert.dgc.v?.first)
        vaccination.co = "XY"
        let extendedToken = ExtendedCBORWebToken(vaccinationCertificate: token,
                                                 vaccinationQRCodeData: "")
        sut = .init(
            router: router,
            resolver: resolver,
            pdfGenerator: pdfGenerator,
            fileManager: .default,
            token: extendedToken,
            coseSign1Message: .mock(),
            timestamp: .init(timeIntervalSinceReferenceDate: 0)
        )

        // When
        let isEnabled = sut.enableCreatePDF

        // Then
        XCTAssertFalse(isEnabled)
    }
}

private extension CBORWebToken {
    static var mockCertificate: CBORWebToken {
        let date = Date(timeIntervalSinceReferenceDate: 0)
        return CBORWebToken(
            iss: "DE",
            iat: date,
            exp: Calendar.current.date(byAdding: .year, value: 1, to: date),
            hcert: HealthCertificateClaim(
                dgc: DigitalGreenCertificate(
                    nam: Name(
                        gn: "Doe",
                        fn: "John",
                        gnt: "DOE",
                        fnt: "JOHN"
                    ),
                    dob: DateUtils.isoDateFormatter.date(from: "1990-01-01"),
                    dobString: "1990-01-01",
                    v: [
                        Vaccination(
                            tg: "840539006",
                            vp: "1119349007",
                            mp: "EU/1/20/1528",
                            ma: "ORG-100001699",
                            dn: 2,
                            sd: 2,
                            dt: DateUtils.isoDateFormatter.date(from: "2021-01-01")!,
                            co: "DE",
                            is: "Robert Koch-Institut iOS",
                            ci: "URN:UVCI:01DE/IZ12345A/4O2O25ZXNQED2R69JTL6FQ#P"
                        )
                    ],
                    ver: "1.0.0"
                )
            )
        )
    }
}
