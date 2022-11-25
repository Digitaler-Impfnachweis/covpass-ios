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

    func testEquality_match() {
        // Given
        let sut1 = Name(gnt: "ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "ERIKA", fnt: "MUSTERMANN")

        // When & Then
        XCTAssertEqual(sut1, sut2)
    }

    func testEquality_no_match_in_gnt() {
        // Given
        let sut1 = Name(gnt: "ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "ANGELIKA", fnt: "MUSTERMANN")

        // When & Then
        XCTAssertNotEqual(sut1, sut2)
    }

    func testEquality_no_match_in_fnt() {
        // Given
        let sut1 = Name(gnt: "ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "ERIKA", fnt: "BEISPIELFRAU")

        // When & Then
        XCTAssertNotEqual(sut1, sut2)
    }

    func testEquality_match_despite_optional_middle_name() {
        // Given
        let sut1 = Name(gnt: "ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "ERIKA<MARIA", fnt: "MUSTERMANN")

        // When & Then
        XCTAssertEqual(sut1, sut2)
    }

    func testEquality_match_despite_last_name_addendum() {
        // Given
        let sut1 = Name(gnt: "ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "ERIKA", fnt: "MUSTERMANN<GABLER")

        // When & Then
        XCTAssertEqual(sut1, sut2)
    }

    func testEquality_match_for_twins_with_same_middle_name_false_positive() {
        // Given
        let sut1 = Name(gnt: "ERIKA<MARIA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "ANGELIKA<MARIA", fnt: "MUSTERMANN")

        // When & Then
        XCTAssertEqual(sut1, sut2)
    }

    func testEquality_match_despite_leading_and_trailing_chevron() {
        // Given
        let sut1 = Name(gnt: "ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "<ERIKA<", fnt: "<MUSTERMANN<")

        // When & Then
        XCTAssertEqual(sut1, sut2)
    }

    func testEquality_no_match_because_of_matching_chevrons() {
        // Given
        let sut1 = Name(gnt: "<ERIKA<", fnt: "<MUSTERMANN<")
        let sut2 = Name(gnt: "<ANGELIKA<", fnt: "<MUSTERMANN<")

        // When & Then
        XCTAssertNotEqual(sut1, sut2)
    }

    func testEquality_match_despite_leading_and_trailing_whitespace() {
        // Given
        let sut1 = Name(gnt: "ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: " ERIKA ", fnt: " MUSTERMANN ")

        // When & Then
        XCTAssertEqual(sut1, sut2)
    }

    func testEquality_no_match_because_of_matching_whitespace() {
        // Given
        let sut1 = Name(gnt: " ERIKA ", fnt: " MUSTERMANN ")
        let sut2 = Name(gnt: " ANGELIKA ", fnt: " MUSTERMANN ")

        // When & Then
        XCTAssertNotEqual(sut1, sut2)
    }

    func testEquality_match_despite_doctors_degree_in_fnt() {
        // Given
        let sut1 = Name(gnt: "ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "ERIKA", fnt: "DR<MUSTERMANN")

        // When & Then
        XCTAssertEqual(sut1, sut2)
    }

    func testEquality_match_despite_doctors_degree_in_fnt_two_chevrons() {
        // Given
        let sut1 = Name(gnt: "ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "ERIKA", fnt: "DR<<MUSTERMANN")

        // When & Then
        XCTAssertEqual(sut1, sut2)
    }

    func testEquality_match_despite_doctors_degree_in_gnt() {
        // Given
        let sut1 = Name(gnt: "DR<ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "ERIKA", fnt: "MUSTERMANN")

        // When & Then
        XCTAssertEqual(sut1, sut2)
    }

    func testEquality_match_despite_doctors_degree_in_gnt_two_chevrons() {
        // Given
        let sut1 = Name(gnt: "DR<<ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "ERIKA", fnt: "DR<<MUSTERMANN")

        // When & Then
        XCTAssertEqual(sut1, sut2)
    }

    func testEquality_no_match_no_match_because_of_matching_doctors_degree_in_gnt() {
        // Given
        let sut1 = Name(gnt: "DR<<ERIKA", fnt: "MUSTERMANN")
        let sut2 = Name(gnt: "DR<<ANGELIKA", fnt: "MUSTERMANN")

        // When & Then
        XCTAssertNotEqual(sut1, sut2)
    }

    func testEquality_no_match_no_match_because_of_matching_doctors_degree_in_fnt() {
        // Given
        let sut1 = Name(gnt: "ERIKA", fnt: "DR<<MUSTERMANN")
        let sut2 = Name(gnt: "ERIKA", fnt: "DR<<BEISPIELFRAU")

        // When & Then
        XCTAssertNotEqual(sut1, sut2)
    }
}
