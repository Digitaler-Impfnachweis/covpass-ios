//
//  LocaleExtensionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class LocaleExtensionTests: XCTestCase {
    func testLocaleIsGerman() {
        XCTAssert(Locale(identifier: "de").isGerman())
        XCTAssertFalse(Locale(identifier: "en").isGerman())
    }
}
