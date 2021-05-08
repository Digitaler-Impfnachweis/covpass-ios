//
//  ArrayExtensionTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import XCTest

@testable import VaccinationCommon

class ArrayExtensionTests: XCTestCase {
    let sut = [72, 101, 108, 108, 111, 33, 33]

    func testChunked() {
        XCTAssertEqual(sut.chunked(into: 3).count, 3)
    }
}
