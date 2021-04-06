//
//  DotLayerTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class DotLayerTests: XCTestCase {
    // MARK: - Subject under test

    var sut: DotLayer!

    // MARK: - Tests

    func testDotLayerInit() {
        // Given
        let origin = CGPoint(x: 10, y: 15)
        let dotSize: CGFloat = 20.0
        let color: UIColor = .blue

        // When
        sut = DotLayer(at: origin, width: dotSize, color: color)

        // Then
        let expectedPath = UIBezierPath()
        expectedPath.addArc(withCenter: CGPoint(x: dotSize / 2, y: dotSize / 2), radius: dotSize / 2, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: false)
        XCTAssertEqual(sut.path, expectedPath.cgPath)
        XCTAssertNil(sut.backgroundColor)
        XCTAssertEqual(sut.fillColor, color.cgColor)
        XCTAssertEqual(sut.frame.origin, CGPoint(x: 10, y: 15))
        XCTAssertEqual(sut.frame.size, CGSize(width: 20.0, height: 20.0))
    }
}
