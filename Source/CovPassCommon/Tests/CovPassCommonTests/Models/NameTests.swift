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
        name2.gnt = "foo"
        XCTAssertNotEqual(name1, name2)

        name1 = sut
        name2 = sut
        name2.fnt = "foo"
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

        name1 = sut
        name2 = sut
        name1.fn = "FOO"
        name1.fnt = "FOO"
        name2.fn = "foo"
        name2.fnt = "FOO"
        XCTAssertEqual(name1, name2)

        name1 = sut
        name2 = sut
        let name3 = sut
        name1.fn = "Dörte"
        name1.fnt = "DOERTE"
        name2.fn = "Dorte"
        name2.fnt = "DOERTE"
        name3.fn = "Doerte"
        name3.fnt = "DOERTE"
        XCTAssertEqual(name1, name2)
        XCTAssertEqual(name1, name3)
    }

    func testTrim() {
        let obj = [
            "fn": " foo ",
            "fnt": " foo ",
            "gn": " foo ",
            "gnt": " foo "
        ]
        let data = try! JSONSerialization.data(withJSONObject: obj, options: .fragmentsAllowed)
        let sut = try! JSONDecoder().decode(Name.self, from: data)
        XCTAssertEqual(sut.gn, "foo")
        XCTAssertEqual(sut.fn, "foo")
        XCTAssertEqual(sut.gnt, "foo")
        XCTAssertEqual(sut.fnt, "foo")
    }

    func testFullName() {
        XCTAssertEqual(sut.fullName, "Erika Dörte Schmitt Mustermann")
        XCTAssertEqual(sut.fullNameReverse, "Schmitt Mustermann, Erika Dörte")
        XCTAssertEqual(sut.fullNameTransliterated, "ERIKA<DOERTE SCHMITT<MUSTERMANN")
        XCTAssertEqual(sut.fullNameTransliteratedReverse, "SCHMITT<MUSTERMANN, ERIKA<DOERTE")
    }
}
