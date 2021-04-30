//
//  PrimaryButtonContainerTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class PrimaryButtonContainerTests: XCTestCase {
    var sut: MainButton!

    override func setUp() {
        super.setUp()
        sut = MainButton()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        XCTAssertNotNil(sut.contentView, "Button ContentView should exist")

        let viewWithFrame = MainButton(frame: .zero)
        XCTAssertNotNil(viewWithFrame.contentView, "Button ContentView should exist")

        let viewWithCoder = MainButton(coder: CoderMock.unarchivedCoder)
        viewWithCoder?.awakeFromNib()
        viewWithCoder?.prepareForInterfaceBuilder()
        XCTAssertNotNil(viewWithCoder, "Button should exist")
        XCTAssertNotNil(viewWithCoder!.contentView, "Button ContentView should exist")
    }

    func testInspectablesDefaultValues() {
        XCTAssertEqual(sut.enabledButtonTextColor, .onBrandAccent)
        XCTAssertEqual(sut.disabledButtonTextColor, .onBackground50)
        XCTAssertEqual(sut.enabledButtonBackgroundColor, .brandAccent70)
        XCTAssertEqual(sut.disabledButtonBackgroundColor, .onBackground20)
        XCTAssertEqual(sut.shadowColor, .primaryButtonShadow)
        XCTAssertEqual(sut.shadowOffset, CGSize(width: 0, height: 3))
        XCTAssertEqual(sut.cornerRadius, UIConstants.Size.ButtonCornerRadius)
        XCTAssertEqual(sut.shadowRadius, UIConstants.Size.ButtonShadowRadius)
    }

    func testStyles() {
        // Shadow
        XCTAssertEqual(sut.layer.shadowRadius, sut.shadowRadius)
        XCTAssertEqual(sut.layer.shadowOpacity, 0.6)
        XCTAssertEqual(sut.layer.shadowOffset, sut.shadowOffset)
        XCTAssertFalse(sut.layer.masksToBounds)
        XCTAssertEqual(sut.layer.shadowColor, sut.shadowColor.cgColor)

        // Corners
//        XCTAssertEqual(sut.layer.cornerRadius, sut.cornerRadius) // The button will never have a custom corner radius. We should refactor that.
        XCTAssertFalse(sut.layer.masksToBounds)

        // Title
        XCTAssertTrue(sut.textableView.isHidden)
        XCTAssertEqual(sut.textableView.textColor, .onBrandAccent)
//        XCTAssertEqual(sut.textableView.font, UIFontMetrics.default.scaledFont(for: UIConstants.Font.semiBold, maximumPointSize: HUIConstants.Font.semiBold.pointSize * 2))
        XCTAssertEqual(sut.textableView.numberOfLines, 0)
//        XCTAssertTrue(sut.textableView.adjustsFontForContentSizeCategory)

        XCTAssertEqual(sut.innerButton.titleColor(for: .normal), .onBrandAccent)
//        XCTAssertEqual(sut.innerButton.titleLabel?.font, UIFontMetrics.default.scaledFont(for: UIConstants.Font.semiBold, maximumPointSize: UIConstants.Font.semiBold.pointSize * 2))
//        XCTAssertEqual(sut.innerButton.titleLabel?.numberOfLines, 0)
//        XCTAssertTrue(sut.innerButton.titleLabel?.adjustsFontForContentSizeCategory ?? true)

        // Background
        XCTAssertEqual(sut.backgroundColor, .brandAccent)
        XCTAssertEqual(sut.contentView?.backgroundColor, .clear)

        // Dot Pulse Animation
        XCTAssertEqual(sut.dotPulseActivityView.color, .backgroundSecondary)
        XCTAssertEqual(sut.dotPulseActivityView.numberOfDots, 3)
        XCTAssertEqual(sut.dotPulseActivityView.padding, 5)
    }

    func testAction() {
        var actionExecuted = false
        sut.action = {
            actionExecuted = true
        }
        sut.innerButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(actionExecuted, "Action should be executed")
    }

    func testTitle() {
        XCTAssertTrue(sut.title.isEmpty)
    }

    func testTextable() {
        // Given
        let testTitle = "test title"

        // When
        sut.text = testTitle

        // Then
        XCTAssertEqual(sut.text, testTitle)
    }

    func testStartAnimation() {
        // When
        sut.startAnimating()

        // Then
        XCTAssertEqual(sut.dotPulseActivityView.isAnimating, true)
        XCTAssertEqual(sut.innerButton.title(for: .normal), "")
        XCTAssertEqual(sut.textableView.text, "")
        XCTAssertTrue(sut.textableView.isHidden)

        XCTAssertTrue(sut.buttonWidthConstraint?.isActive ?? false)
        XCTAssertTrue(sut.buttonHeightConstraint?.isActive ?? false)
    }

    func testStopAnimation() {
        // When
        sut.startAnimating()
        sut.stopAnimating()

        // Then
        XCTAssertEqual(sut.dotPulseActivityView.isAnimating, false)

        XCTAssertFalse(sut.buttonWidthConstraint?.isActive ?? false)
        XCTAssertFalse(sut.buttonHeightConstraint?.isActive ?? false)
    }

    func testStopAnimationOnTitleButton() {
        // Given
        sut.title = "Random title"

        // When
        sut.startAnimating()
        sut.stopAnimating()

        // Then
        XCTAssertEqual(sut.dotPulseActivityView.isAnimating, false)
        XCTAssertTrue(sut.textableView.isHidden)
        XCTAssertEqual(sut.textableView.text, "Random title")
        XCTAssertEqual(sut.innerButton.title(for: .normal), "Random title")

        XCTAssertFalse(sut.buttonWidthConstraint?.isActive ?? false)
        XCTAssertFalse(sut.buttonHeightConstraint?.isActive ?? false)
    }

    func testEnable() {
        // When
        sut.enable()

        // Then
        XCTAssertTrue(sut.isEnabled, "Button should be enabled.")
        XCTAssertTrue(sut.textableView.isHidden)
        XCTAssertEqual(sut.textableView.textColor, .onBrandAccent, "TextableView text color should match.")
        XCTAssertEqual(sut.innerButton.titleColor(for: .normal), .onBrandAccent)
        XCTAssertEqual(sut.backgroundColor, .brandAccent, "Button background color should match.")
    }

    func testDisable() {
        // When
        sut.disable()

        // Then
        XCTAssertFalse(sut.isEnabled, "Button should not be enabled.")
        XCTAssertTrue(sut.textableView.isHidden)
        XCTAssertEqual(sut.textableView.textColor, .onBackground50, "TextableView text color should match.")
        XCTAssertEqual(sut.innerButton.titleColor(for: .normal), .onBackground50)
        XCTAssertEqual(sut.backgroundColor, .onBackground20, "Button background color should match.")
    }

    func testButtonAction() {
        var buttonPressed = false

        sut.action = {
            buttonPressed = true
        }

        sut.innerButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(buttonPressed)
    }
}
