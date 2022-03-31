//
//  String+SVGTests.swift
//  
//
//  Created by Thomas Kuleßa on 14.03.22.
//

@testable import CovPassUI
import XCTest

class String_SVGTests: XCTestCase {
    func testTSpan_empty() {
        // Given
        let sut = ""

        // When
        let tspans = sut.svgTspans(nrOfCharacters: 1, yStart: 0, lineSpacing: 1)

        // Then
        XCTAssertTrue(tspans.isEmpty)
    }

    func testTSpan_short_line() {
        // Given
        let sut = "Line 1"

        // When
        let tspans = sut.svgTspans(nrOfCharacters: 100, yStart: 1, lineSpacing: 1)

        // Then
        XCTAssertEqual(tspans, "<tspan x=\"0\" y=\"1\">Line 1</tspan>")
    }

    func testTSpan_multiple_lines() {
        // Given
        let expectedTspans = "<tspan x=\"0\" y=\"1\">Line 1</tspan><tspan x=\"0\" y=\"4\">Line 2</tspan><tspan x=\"0\" y=\"7\">Line 3</tspan><tspan x=\"0\" y=\"10\">Line 4</tspan><tspan x=\"0\" y=\"13\">Line 5</tspan><tspan x=\"0\" y=\"16\">Line 6</tspan><tspan x=\"0\" y=\"19\">Shrt</tspan>"
        let sut = "Line 1Line 2Line 3Line 4Line 5Line 6Shrt"

        // When
        let tspans = sut.svgTspans(nrOfCharacters: 6, yStart: 1, lineSpacing: 3)

        // Then
        XCTAssertEqual(tspans, expectedTspans)
    }
}
