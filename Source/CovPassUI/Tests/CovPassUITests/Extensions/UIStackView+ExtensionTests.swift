//
//  UIStackView+ExtensionTests.swift
//  
//
//  Created by Thomas Kuleßa on 18.05.22.
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
