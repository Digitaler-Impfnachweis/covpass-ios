//
//  DotPageIndicatorTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class DotPageIndicatorTests: XCTestCase {
    var sut: DotPageIndicator!
    let numberOfDots = 4

    override func setUp() {
        sut = DotPageIndicator(frame: CGRect.zero, numberOfDots: numberOfDots)
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInitWithCoder() {
        let indicatorWithCoder = DotPageIndicator(coder: CoderMock.unarchivedCoder)
        XCTAssertNotNil(indicatorWithCoder, "Dot indicator contentView should exist.")
        XCTAssertEqual(indicatorWithCoder?.selectedDotIndex, 0, "Selected dot index should match.")
        XCTAssertEqual(indicatorWithCoder?.backgroundColor, UIColor.clear, "Background color should match.")
    }

    func testCustomInits() {
        // Init with frame and number of dots.
        let indicatorWithFrame = DotPageIndicator(frame: CGRect.zero, numberOfDots: numberOfDots)
        XCTAssertNotNil(indicatorWithFrame, "Dot indicator contentView should exist.")
        XCTAssertEqual(indicatorWithFrame.numberOfDots, numberOfDots, "Number of dots should match.")
        XCTAssertEqual(indicatorWithFrame.dots.count, numberOfDots, "Number of dots should match.")
        XCTAssertEqual(indicatorWithFrame.selectedDotIndex, 0, "Selected dot index should match.")
        XCTAssertEqual(indicatorWithFrame.unselectedColor, .brandAccent20, "Dot background color should match.")
        XCTAssertEqual(indicatorWithFrame.backgroundColor, UIColor.clear, "Background color should match.")

        // Init with frame, number of dots and dot background color.
        let dotColor = UIColor.blue
        let indicator = DotPageIndicator(frame: CGRect.zero, numberOfDots: numberOfDots, color: dotColor)
        XCTAssertNotNil(indicator, "Dot indicator contentView should exist.")
        XCTAssertEqual(indicator.numberOfDots, numberOfDots, "Number of dots should match.")
        XCTAssertEqual(indicator.dots.count, numberOfDots, "Number of dots should match.")
        XCTAssertEqual(indicator.selectedDotIndex, 0, "Selected dot index should match.")
        XCTAssertEqual(indicator.unselectedColor, dotColor, "Dot background color should match.")
        XCTAssertEqual(indicator.backgroundColor, UIColor.clear, "Background color should match.")
    }

    func testSelectDot() {
        let newSelectionIndex = numberOfDots - 1
        XCTAssertEqual(sut.selectedDotIndex, 0, "Selected dot index should match.")
        XCTAssertEqual(sut.dots[sut.selectedDotIndex].alpha, 1.0, "Selected dot alpha should match.")
        sut.selectDot(withIndex: newSelectionIndex)
        XCTAssertEqual(sut.selectedDotIndex, newSelectionIndex, "Selected dot index should match.")
        XCTAssertEqual(sut.dots[newSelectionIndex].alpha, 1.0, "Selected dot alpha should match.")
    }

    func testUnselectedColor() {
        XCTAssertEqual(sut.unselectedColor, .brandAccent20)
    }

    func testSelectedColor() {
        XCTAssertEqual(sut.selectedColor, .brandAccent70)
    }
}
