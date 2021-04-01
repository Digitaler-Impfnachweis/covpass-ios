//
//  HUIPrimaryIconButtonContainerTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

struct CoderMock {
    static var unarchivedCoder: NSCoder {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: Data(), requiringSecureCoding: false),
            let coder = try? NSKeyedUnarchiver(forReadingFrom: data) else {
            return NSCoder()
        }
        return coder
    }
}

class PrimaryIconButtonContainerTests: XCTestCase {
    func testInit() {
        let view = PrimaryIconButtonContainer()
        XCTAssertNotNil(view.contentView, "Button ContentView should exist")

        let viewWithFrame = PrimaryIconButtonContainer(frame: CGRect.zero)
        XCTAssertNotNil(viewWithFrame.contentView, "Button ContentView should exist")

        let viewWithCoder = PrimaryIconButtonContainer(coder: CoderMock.unarchivedCoder)
        viewWithCoder?.awakeFromNib()
        viewWithCoder?.prepareForInterfaceBuilder()
        XCTAssertNotNil(viewWithCoder, "Button should exist")
        XCTAssertNotNil(viewWithCoder!.contentView, "Button ContentView should exist")

        XCTAssertNotNil(viewWithCoder!.icon.image, "Image should exist")
    }

    func testTitle() {
        let view = PrimaryIconButtonContainer()
        XCTAssertNil(view.innerButton.currentTitle, "Title should be nil")
    }

    func testStartAnimation() {
        // Given
        let view = PrimaryIconButtonContainer()

        // When
        view.startAnimating(makeCircle: true)

        // Then
        XCTAssertEqual(view.dotPulseActivityView.isAnimating, true)
        XCTAssertEqual(view.icon.isHidden, true)
    }

    func testStopAnimation() {
        // Given
        let view = PrimaryIconButtonContainer()

        // When
        view.startAnimating(makeCircle: true)
        view.stopAnimating()

        // Then
        XCTAssertEqual(view.dotPulseActivityView.isAnimating, false)
        XCTAssertEqual(view.icon.isHidden, false)
    }

    func testSettingIconImage() {
        // Given
        let view = PrimaryIconButtonContainer()
        let testImage = UIImage(named: UIConstants.IconName.CheckmarkIcon, in: UIConstants.bundle, compatibleWith: nil)
        // When
        view.iconImage = testImage
        // Then
        XCTAssertEqual(view.icon.image, testImage)
    }
}
