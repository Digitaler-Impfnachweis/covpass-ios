//
//  UIStackView+ExtensionTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import UIKit
import XCTest

class UIStackViewExtensionTests: XCTestCase {
    func testRemoveAllArrangedSubviews() {
        // Given
        let sut = UIStackView()
        sut.addArrangedSubview(UIView())
        sut.addArrangedSubview(UIButton())
        sut.addArrangedSubview(UILabel())

        // When
        sut.removeAllArrangedSubviews()

        // Then
        XCTAssertTrue(sut.arrangedSubviews.isEmpty)
    }
}
