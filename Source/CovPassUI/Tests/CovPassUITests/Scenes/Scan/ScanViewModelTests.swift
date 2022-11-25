//
//  ScanViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
@testable import CovPassUI
import PromiseKit
import XCTest

class ScanViewModelTests: XCTestCase {
    var certificateRepository: VaccinationRepositoryMock!
    var delegate: ScanViewModelDelegateMock!
    var promise: Promise<QRCodeImportResult>!
    var pdfCBORExtractor: CertificateExtractorMock!
    var sut: ScanViewModel!
    var router: ScanRouterMock!

    override func setUp() {
        super.setUp()
        let (promise, resolver) = Promise<QRCodeImportResult>.pending()
        self.promise = promise
        delegate = ScanViewModelDelegateMock()
        router = ScanRouterMock()
        certificateRepository = .init()
        pdfCBORExtractor = .init()
        sut = ScanViewModel(
            cameraAccessProvider: CameraAccessProviderMock(),
            resolvable: resolver,
            router: router,
            isDocumentPickerEnabled: false,
            certificateExtractor: pdfCBORExtractor,
            certificateRepository: certificateRepository
        )
        sut.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        promise = nil
        sut = nil
        router = nil
        certificateRepository = nil
        pdfCBORExtractor = nil
        super.tearDown()
    }

    func testDocumentPickerActionSheetDocument() {
        // GIVEN
        router.choosenDocumentType = .document

        // WHEN
        sut.documentPicker()

        // THEN
        wait(for: [router.showDocumentPickerExpectation], timeout: 1.0)
    }

    func testDocumentPickerActionSheetPhoto() {
        // GIVEN
        router.choosenDocumentType = .photo

        // WHEN
        sut.documentPicker()

        // THEN
        wait(for: [router.showDocumentPickerExpectation], timeout: 1.0)
    }

    func testDocumentPicker_cancel() {
        // Given
        router.choosenDocumentType = .cancel
        delegate.viewModelDidChangeExpectation.expectedFulfillmentCount = 2

        // When
        sut.documentPicker()

        // Then
        wait(for: [
            router.showDocumentPickerExpectation,
            delegate.viewModelDidChangeExpectation
        ], timeout: 1.0)
        XCTAssertEqual(sut.mode, .scan)
    }

    func testDocumentPicker() {
        // When
        sut.documentPicker()

        // Then
        XCTAssertEqual(sut.mode, .selection)
    }

    func testDocumentPicked() throws {
        // Given
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "Test QR Codes", withExtension: "pdf")
        )
        let token = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: "1"
        )
        pdfCBORExtractor.extractionResult = [token]

        // When
        sut.documentPicked(at: [url])

        // Then
        wait(for: [
            router.showCertificatePickerExpectation,
            delegate.viewModelDidChangeExpectation
        ], timeout: 1)
        XCTAssertEqual(sut.mode, .scan)
        XCTAssertEqual(router.receivedTokens, [token])
    }

    func testDocumentPicked_dependencies_missing() throws {
        // Given
        let url = FileManager.default.temporaryDirectory
        let (_, resolver) = Promise<QRCodeImportResult>.pending()
        sut = .init(
            cameraAccessProvider: CameraAccessProviderMock(),
            resolvable: resolver,
            router: router,
            isDocumentPickerEnabled: false,
            certificateExtractor: nil,
            certificateRepository: nil
        )
        router.showCertificatePickerExpectation.isInverted = true

        // When
        sut.documentPicked(at: [url])

        // Then
        wait(for: [router.showCertificatePickerExpectation], timeout: 1)
    }

    func testImagePicked() throws {
        // Given
        let image = UIImage()
        let token = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: "1"
        )
        pdfCBORExtractor.extractionResult = [token]

        // When
        sut.imagePicked(images: [image])

        // Then
        wait(for: [
            router.showCertificatePickerExpectation,
            delegate.viewModelDidChangeExpectation
        ], timeout: 1)
        XCTAssertEqual(sut.mode, .scan)
        XCTAssertEqual(router.receivedTokens, [token])
    }

    func testImagePicked_dependencies_missing() throws {
        // Given
        let image = UIImage()
        let (_, resolver) = Promise<QRCodeImportResult>.pending()
        sut = .init(
            cameraAccessProvider: CameraAccessProviderMock(),
            resolvable: resolver,
            router: router,
            isDocumentPickerEnabled: false,
            certificateExtractor: nil,
            certificateRepository: nil
        )
        router.showCertificatePickerExpectation.isInverted = true

        // When
        sut.imagePicked(images: [image])

        // Then
        wait(for: [router.showCertificatePickerExpectation], timeout: 1)
    }

    func testMode() {
        // When
        let mode = sut.mode

        // Then
        XCTAssertEqual(mode, .scan)
    }

    func testMode_set() {
        // When
        sut.mode = .selection

        // Then
        wait(for: [delegate.viewModelDidChangeExpectation], timeout: 1)
    }
}
