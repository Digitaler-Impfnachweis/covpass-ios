//
//  DotPulseActivityIndicatorTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class DotPulseActivityIndicatorTests: XCTestCase {
    // MARK: - subject under test

    var sut: DotPulseActivityIndicator!
    let frame = CGRect(x: 0, y: 0, width: 89, height: 24)

    override func setUp() {
        super.setUp()
        sut = DotPulseActivityIndicator(frame: frame, color: .blue, padding: 2)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDefaultSetUp() {
        // When
        sut = DotPulseActivityIndicator(frame: frame)

        // Then
        XCTAssertEqual(sut.color, UIConstants.BrandColor.brandAccent70)
        XCTAssertEqual(sut.padding, 0.0)
        XCTAssertEqual(sut.backgroundColor, UIColor.clear)
    }

    func testStartAnimating() {
        // Given
        sut.numberOfDots = 5

        // When
        sut.startAnimating()

        // Then
        XCTAssertFalse(sut.isHidden)
        XCTAssertTrue(sut.isAnimating)
        XCTAssertEqual(sut.layer.sublayers?.count, 5)
    }

    func testStopAnimating() {
        // Given
        sut.numberOfDots = 5

        // When
        sut.stopAnimating()

        // Then
        XCTAssertFalse(sut.isAnimating)
        XCTAssertNil(sut.layer.sublayers)
    }

    func testDotLayerLayout() {
        // Given
        sut.numberOfDots = 3

        // When
        sut.startAnimating()

        // Then
        let thirdDot = sut.layer.sublayers![2] as? DotLayer

        let expectedOrigin = CGPoint(x: 67.0, y: 2.0)
        XCTAssertEqual(thirdDot?.frame.origin, expectedOrigin)
        let expectedInitialSize = CGSize(width: 15.0, height: 15.0)
        XCTAssertEqual(thirdDot?.frame.size, expectedInitialSize)
        XCTAssertEqual(thirdDot?.fillColor, UIColor.blue.cgColor)
    }

    func testDotLayerAnimation() {
        // Given
        sut.numberOfDots = 3

        // When
        sut.startAnimating()

        // Then
        let thirdDot = sut.layer.sublayers![2] as? DotLayer
        let beginTime = CACurrentMediaTime()
        let groupAnimation = thirdDot?.animation(forKey: "animation") as? CAAnimationGroup

        XCTAssertEqual(groupAnimation?.animations?.count, 2)
        XCTAssertEqual((groupAnimation?.beginTime)!, beginTime + 0.6, accuracy: 0.01)

        // Test scale animation
        let scaleAnimation = groupAnimation?.animations?.first as? CAKeyframeAnimation
        XCTAssertEqual(scaleAnimation?.keyPath, "transform.scale")
        XCTAssertEqual(Double((scaleAnimation?.duration)!), 0.9, accuracy: 0.001)
        XCTAssertEqual(scaleAnimation?.keyTimes, [0, 0.3, 0.6])
        let expectedScaleValues = [1.0, 16.0 / 12.0, 1.0]
        for idx in 0 ..< 3 {
            let scaleAnimationValue = Double((scaleAnimation?.values![idx] as? CGFloat)!)
            XCTAssertEqual(scaleAnimationValue, expectedScaleValues[idx], accuracy: 0.1)
        }

        // Test opacity animation
        let opacityAnimation = groupAnimation?.animations?.last as? CAKeyframeAnimation
        XCTAssertEqual(opacityAnimation?.keyPath, "opacity")
        XCTAssertEqual(Double((opacityAnimation?.duration)!), 0.9, accuracy: 0.001)
        let expectedOpacityValues = [0.4, 1.0, 0.4]
        for idx in 0 ..< 3 {
            let opacityAnimationValue = Double((opacityAnimation?.values![idx] as? CGFloat)!)
            XCTAssertEqual(opacityAnimationValue, expectedOpacityValues[idx], accuracy: 0.1)
        }
    }
}
