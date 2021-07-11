//
//  VaccinationTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class NameTests: XCTestCase {
    var sut: Name {
        try! JSONDecoder().decode(Name.self, from: Data.json("Name"))
    }

    func testDecoding() {
        XCTAssertEqual(sut.gn, "Erika Dörte")
        XCTAssertEqual(sut.fn, "Schmitt Mustermann")
        XCTAssertEqual(sut.gnt, "ERIKA<DOERTE")
        XCTAssertEqual(sut.fnt, "SCHMITT<MUSTERMANN")
    }

    func testComparision() {
        var name1 = sut
        var name2 = sut
        XCTAssertEqual(name1, name2)

        name1 = sut
        name2 = sut
        name2.gn = "foo"
        XCTAssertNotEqual(name1, name2)

        name1 = sut
        name2 = sut
        name2.fn = "foo"
        XCTAssertNotEqual(name1, name2)

        name1 = sut
        name2 = sut
        name2.fn = nil
        name2.gn = nil
        name2.gnt = "foo"
        XCTAssertNotEqual(name1, name2)

        name1 = sut
        name2 = sut
        name2.fn = nil
        name2.gn = nil
        name2.fnt = "foo"
        XCTAssertNotEqual(name1, name2)
    }
}
