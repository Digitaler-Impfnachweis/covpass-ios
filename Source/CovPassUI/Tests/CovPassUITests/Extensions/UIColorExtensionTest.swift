//
//  UIColorExtensionTest.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import XCTest

class UIColorExtensionTest: XCTestCase {
    // MARK: - Basic Tests

    let denimColorRGBA = UIColor(red: 0.168627450980392, green: 0.447058823529412, blue: 0.713725490196078, alpha: 1.0)

    func testStringToColor() {
        let denimColor = UIColor(hexString: "2B72B6")
        XCTAssert(denimColor.description == denimColorRGBA.description)
    }

    func testHashTagInput() {
        let hashCode = UIColor(hexString: "#2B72B6")
        XCTAssert(hashCode.description == denimColorRGBA.description)
    }
}
