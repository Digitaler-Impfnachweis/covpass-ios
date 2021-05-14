//
//  VaccinationTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import VaccinationCommon

import Foundation
import XCTest

class NameTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("Name")
        let sut = try! JSONDecoder().decode(Name.self, from: jsonData)

        XCTAssertEqual(sut.gn, "Erika Dörte")
        XCTAssertEqual(sut.fn, "Schmitt Mustermann")
        XCTAssertEqual(sut.gnt, "ERIKA<DOERTE")
        XCTAssertEqual(sut.fnt, "SCHMITT<MUSTERMANN")
    }
}
