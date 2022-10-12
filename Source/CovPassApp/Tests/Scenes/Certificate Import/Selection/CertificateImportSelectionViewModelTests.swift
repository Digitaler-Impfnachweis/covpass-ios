//
//  CertificateImportSelectionViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import PromiseKit
import XCTest

class CertificateImportSelectionViewModelTests: XCTestCase {
    private var delegate: MockViewModelDelegate!
    private var promise: Promise<Void>!
    private var resolver: Resolver<Void>!
    private var router: CertificateImportSelectionRouterMock!
    private var sut: CertificateImportSelectionViewModel!
    private var vaccinationRepository: VaccinationRepositoryMock!

    override func setUpWithError() throws {
        let tokens: [ExtendedCBORWebToken] = try [
            .mock(),
            .token1Of1(),
            .token1Of2(),
            .token3Of3()
        ]
        vaccinationRepository = .init()
        router = .init()
        delegate = .init()
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        self.resolver = resolver
        configureSut(tokens: tokens)
    }

    private func configureSut(tokens: [ExtendedCBORWebToken]) {
        sut = .init(
            tokens: tokens,
            vaccinationRepository: vaccinationRepository,
            resolver: resolver,
            router: router
        )
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        delegate = nil
        promise = nil
        resolver = nil
        router = nil
        sut = nil
        vaccinationRepository = nil
    }

    func testButtonTitle_nothing_selected() {
        // When
        sut.items.forEach { $0.selected = false }
        let buttonTitle = sut.buttonTitle

        // Then
        XCTAssertEqual(buttonTitle, "Import 0 certificate(s)")
    }

    func testButtonTitle_some_selected() {
        // Given
        sut.items.forEach { $0.selected = false }
        sut.items.first?.selected = true
        sut.items.last?.selected = true

        // When
        let buttonTitle = sut.buttonTitle

        // Then
        XCTAssertEqual(buttonTitle, "Import 2 certificate(s)")
    }

    func testButtonTitle_no_tokens() {
        // Given
        configureSut(tokens: [])

        // When
        let buttonTitle = sut.buttonTitle

        // Then
        XCTAssertEqual(buttonTitle, "OK")
    }

    func testSelectionTitle_nothing_selected() {
        // Given
        sut.items.forEach { $0.selected = false }

        // When
        let selectionTitle = sut.selectionTitle

        // Then
        XCTAssertEqual(selectionTitle, "0 of 4 certificate(s) selected")
    }

    func testSelectionTitle_some_selected() {
        // Given
        sut.items.forEach { $0.selected = false }
        sut.items.first?.selected = true
        sut.items.last?.selected = true

        // When
        let selectionTitle = sut.selectionTitle

        // Then
        XCTAssertEqual(selectionTitle, "2 of 4 certificate(s) selected")
    }

    func testItems() {
        // When
        let items = sut.items

        // Then
        guard items.count == 4 else {
            XCTFail("Count must be 4.")
            return
        }
        XCTAssertEqual(items[0].additionalLines.first, "Vaccine dose 2 of 2")
        XCTAssertEqual(items[0].additionalLines.last, "Vaccinated on 02.02.2021")
        XCTAssertEqual(items[1].additionalLines.first, "Vaccine dose 1 of 1")
        XCTAssertEqual(items[1].additionalLines.last, "Vaccinated on 02.02.2021")
        XCTAssertEqual(items[2].additionalLines.first, "Vaccine dose 1 of 2")
        XCTAssertEqual(items[2].additionalLines.last, "Vaccinated on 02.02.2021")
        XCTAssertEqual(items[3].additionalLines.first, "Vaccine dose 3 of 3")
        XCTAssertEqual(items[3].additionalLines.last, "Vaccinated on 02.04.2021")
    }

    func testTitle() {
        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "Select certificates")
    }

    func testTitle_no_tokens() {
        // Given
        configureSut(tokens: [])

        // When
        let title = sut.title

        // Then
        XCTAssertEqual(title, "No valid certificate was found")
    }

    func testHideSelection() {
        // When
        let hideSelection = sut.hideSelection

        // Then
        XCTAssertFalse(hideSelection)
    }

    func testHideSelection_no_tokens() {
        // Given
        configureSut(tokens: [])

        // When
        let hideSelection = sut.hideSelection

        // Then
        XCTAssertTrue(hideSelection)
    }

    func testEnableButton() {
        // When
        sut.items.forEach { $0.selected = false }
        let enableButton = sut.enableButton

        // Then
        XCTAssertFalse(enableButton)
    }

    func testEnableButton_no_tokens() {
        // Given
        configureSut(tokens: [])

        // When
        let enableButton = sut.enableButton

        // Then
        XCTAssertTrue(enableButton)
    }

    func testCancel() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _ in
            expectation.fulfill()
        }.cauterize()

        // When
        sut.cancel()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testConfirm_no_tokens() {
        // Given
        configureSut(tokens: [])
        let expectation = XCTestExpectation()
        promise.done { _ in
            expectation.fulfill()
        }.cauterize()

        // When
        sut.confirm()

        // Then
        XCTAssertFalse(sut.isImportingCertificates)
        wait(for: [expectation], timeout: 1)
    }

    func testConfirm_import_success() {
        // Given
        delegate.viewModelDidUpdateExpectation.expectedFulfillmentCount = 2

        // When
        sut.confirm()

        // Then
        XCTAssertTrue(sut.isImportingCertificates)
        wait(for: [
            vaccinationRepository.updateExpectation,
            router.showImportSuccessExpectation,
            delegate.viewModelDidUpdateExpectation
        ], timeout: 1)
        XCTAssertFalse(sut.isImportingCertificates)
    }

    func testConfirm_import_failure() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _ in
            expectation.fulfill()
        }.cauterize()
        vaccinationRepository.updateError = NSError(domain: "TEST", code: 0)
        router.showImportSuccessExpectation.isInverted = true
        delegate.viewModelDidUpdateExpectation.expectedFulfillmentCount = 2

        // When
        sut.confirm()

        // Then
        wait(for: [
            expectation,
            router.showImportSuccessExpectation,
            delegate.viewModelDidUpdateExpectation
        ], timeout: 1)
        XCTAssertFalse(sut.isImportingCertificates)
    }

    func testConfirm_too_many_certifcate_holders() {
        // Given
        let tokens = (0...20).map { index in
            CBORWebToken.mockVaccinationCertificate.mockName(
                .init(gn: nil, fn: nil, gnt: nil, fnt: "\(index)")
            ).extended()
        }
        delegate.viewModelDidUpdateExpectation.expectedFulfillmentCount = 2
        configureSut(tokens: tokens)

        // When
        sut.confirm()

        // Then
        wait(for: [
            router.showTooManyHoldersErrorExpectation,
            delegate.viewModelDidUpdateExpectation
        ], timeout: 1)
        XCTAssertFalse(sut.isImportingCertificates)
    }

    func testConfirm_too_many_certifcate_holders_including_existing_tokens() {
        // Given
        let tokens = (0...20).map { index in
            CBORWebToken.mockVaccinationCertificate.mockName(
                .init(gn: nil, fn: nil, gnt: nil, fnt: "\(index)")
            ).extended()
        }
        vaccinationRepository.certificates = tokens

        // When
        sut.confirm()

        // Then
        wait(for: [
            router.showTooManyHoldersErrorExpectation
        ], timeout: 1)
    }

    func testToggleSelection_nothing_selected() {
        // Given
        sut.items.forEach { $0.selected = false }

        // When
        sut.toggleSelection()

        // Then
        XCTAssertFalse(
            sut.items.contains{ $0.selected == false }
        )
    }

    func testToggleSelection_all_selected() {
        // When
        sut.toggleSelection()

        // Then
        XCTAssertFalse(
            sut.items.contains{ $0.selected == true }
        )
    }

    func testToggleSelection_some_selected() {
        // Given
        sut.items.first?.selected = false
        sut.items.last?.selected = false

        // When
        sut.toggleSelection()

        // Then
        XCTAssertFalse(
            sut.items.contains{ $0.selected == false }
        )
    }

    func testItemSelectionState_all() {
        // When
        let state = sut.itemSelectionState

        // Then
        XCTAssertEqual(state, .all)
    }

    func testItemSelectionState_some() {
        // Given
        sut.items.first?.selected = false

        // When
        let state = sut.itemSelectionState

        // Then
        XCTAssertEqual(state, .some)
    }

    func testItemSelectionState_none() {
        // Given
        for item in sut.items {
            item.selected = false
        }

        // When
        let state = sut.itemSelectionState

        // Then
        XCTAssertEqual(state, .none)
    }

    func testIsImportingCertificates_default() {
        // When
        let isImportingCertificates = sut.isImportingCertificates

        // Then
        XCTAssertFalse(isImportingCertificates)
    }
}
