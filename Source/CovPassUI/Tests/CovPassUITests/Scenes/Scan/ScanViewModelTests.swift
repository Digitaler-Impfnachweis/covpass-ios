//
//  ScanViewModelTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import CovPassCommon
import XCTest
import PromiseKit

class ScanViewModelTests: XCTestCase {
    var certificateRepository: VaccinationRepositoryMock!
    var pdfCBORExtractor: CertificateExtractorMock!
    var sut: ScanViewModel!
    var router: ScanRouterMock!

    override func setUp() {
        super.setUp()
        let (_, resolver) = Promise<QRCodeImportResult>.pending()
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
    }
    
    override func tearDown() {
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

    func testDocumentPicked() throws {
        // Given
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "Test QR Codes", withExtension: "pdf")
        )
        let token = ExtendedCBORWebToken.init(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: "1"
        )
        pdfCBORExtractor.extractionResult = [token]

        // When
        sut.documentPicked(at: [url])

        // Then
        wait(for: [router.showCertificatePickerExpectation], timeout: 1)
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
        let token = ExtendedCBORWebToken.init(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: "1"
        )
        pdfCBORExtractor.extractionResult = [token]

        // When
        sut.imagePicked(images: [image])

        // Then
        wait(for: [router.showCertificatePickerExpectation], timeout: 1)
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
}
