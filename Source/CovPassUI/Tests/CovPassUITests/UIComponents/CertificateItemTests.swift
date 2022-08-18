//
//  CertificateItemTest.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import XCTest

class CertificateItemTests: XCTestCase {
    func testAccessibilityTraits_action_not_nil() {
        // Given
        let sut = CertificateItem(
            viewModel: CertificateItemViewModelMock(),
            action: {}
        )

        // When
        let traits = sut.accessibilityTraits

        // Then
        XCTAssertTrue(traits.contains(.button))
        XCTAssertFalse(traits.contains(.staticText))
    }

    func testAccessibilityTraits_action_nil() {
        // Given
        let sut = CertificateItem(
            viewModel: CertificateItemViewModelMock(),
            action: nil
        )

        // When
        let traits = sut.accessibilityTraits

        // Then
        XCTAssertFalse(traits.contains(.button))
        XCTAssertTrue(traits.contains(.staticText))
    }

    func testAccessibilityLabel_action_not_nil() throws {
        // Given
        var viewModel = CertificateItemViewModelMock()
        viewModel.certificateItemIsSelectableAccessibilityLabel = "XYZ"
        let sut = CertificateItem(
            viewModel: viewModel,
            action: {}
        )

        // When
        let label = try XCTUnwrap(sut.accessibilityLabel)

        // Then
        XCTAssertTrue(label.contains("XYZ"))
    }

    func testAccessibilityLabel_action_nil() throws {
        // Given
        var viewModel = CertificateItemViewModelMock()
        viewModel.certificateItemIsSelectableAccessibilityLabel = "XYZ"
        let sut = CertificateItem(
            viewModel: viewModel,
            action: nil
        )

        // When
        let label = try XCTUnwrap(sut.accessibilityLabel)

        // Then
        XCTAssertFalse(label.contains("XYZ"))
    }
}
