//
//  CertificateImportSelectionViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import XCTest

class CertificateImportSelectionViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: CertificateImportSelectionViewController!
    private var viewModel: CertificateImportSelectionViewModelMock!
    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = CertificateImportSelectionViewModelMock()
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        viewModel = nil
        try super.tearDownWithError()
    }

    func testSomeSelected() throws {
        // Given
        viewModel.items[2].selected = true
        viewModel.items[4].selected = true
        viewModel.items[5].selected = true
        viewModel.itemSelectionState = .some

        // Then
        verifyView(view: sut.view, height: 1300)
    }

    func testAllSelected() throws {
        // Given
        for item in viewModel.items {
            item.selected = true
        }
        viewModel.itemSelectionState = .all

        // Then
        verifyView(view: sut.view, height: 1300)
    }

    func testNoneSelected() throws {
        // Given
        viewModel.enableButton = false

        // Then
        verifyView(view: sut.view, height: 1300)
    }

    func testEmpty() throws {
        // Given
        viewModel.hideSelection = true
        viewModel.title = "No valid certificate was found"
        viewModel.buttonTitle = "OK"

        // Then
        verifyView(view: sut.view, height: 1300)
    }
}
