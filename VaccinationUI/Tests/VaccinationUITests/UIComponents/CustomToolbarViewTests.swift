//
//  CustomToolbarViewTests.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class CustomToolbarViewTests: XCTestCase {
    var sut: CustomToolbarView!

    override func setUp() {
        super.setUp()
        sut = CustomToolbarView()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        let view = CustomToolbarView()
        XCTAssertNotNil(view.contentView, "View ContentView should exist")

        XCTAssertNotNil(sut.leftButton)
        XCTAssertEqual(sut.navigationIcon, UIConstants.IconName.NavigationArrow)
        XCTAssertEqual(sut.navigationIconColor, UIConstants.BrandColor.onBackground70)
    }

    func testSetup() {
        sut.setUpLeftButton(leftButtonItem: .navigationArrow)
        XCTAssertFalse(sut.leftButton.isHidden)
        XCTAssertTrue(sut.leftButton.isEnabled)
        XCTAssertEqual(sut.leftButton.tintColor, sut.navigationIconColor)

        sut.setUpLeftButton(leftButtonItem: nil)
        XCTAssertEqual(sut.leftButton.isEnabled, false)

        sut.setUpMiddleButton(middleButtonItem: .cancelButton)
        XCTAssertTrue(sut.subviews.last is MainButton)
    }

    func testLeftButtonAction() {
        var actionExecuted = false
        sut.leftButtonAction = {
            actionExecuted = true
        }
        sut.leftButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(actionExecuted, "Action should be executed")
    }

    func test_State_None() {
        // Given
        let state = CustomToolbarState.none

        // When
        sut.state = state

        // Then
        XCTAssertNil(sut.primaryButton)
    }

    func test_State_Cancel() {
        // Given
        let state = CustomToolbarState.cancel

        // When
        sut.state = state

        // Then
        XCTAssertNotNil(sut.primaryButton)
        XCTAssertNotNil(sut.primaryButton as? PrimaryIconButtonContainer)
        XCTAssertTrue(sut.primaryButton.isEnabled)

        XCTAssertEqual(sut.primaryButton.enabledButtonBackgroundColor, UIConstants.BrandColor.onBackground20)
        XCTAssertEqual(sut.primaryButton.tintColor, UIConstants.BrandColor.onBackground70)
    }

    func test_State_Check() {
        // Given
        let state = CustomToolbarState.done

        // When
        sut.state = state

        // Then
        XCTAssertNotNil(sut.primaryButton)
        XCTAssertNotNil(sut.primaryButton as? PrimaryIconButtonContainer)
        XCTAssertTrue(sut.primaryButton.isEnabled)
    }

    func test_State_InProgress() {
        // Given
        let state = CustomToolbarState.inProgress

        // When
        sut.state = state

        // Then
        XCTAssertNotNil(sut.primaryButton)
        XCTAssertTrue(sut.primaryButton.dotPulseActivityView.isAnimating)
        XCTAssertTrue(sut.primaryButton.isEnabled)
    }

    func test_State_ScrollAware() {
        // Given
        let state = CustomToolbarState.scrollAware

        // When
        sut.state = state

        // Then
        XCTAssertNotNil(sut.primaryButton)
        XCTAssertEqual(sut.primaryButton.buttonBackgroundColor, .clear)
        XCTAssertTrue(sut.primaryButton.isEnabled)
    }

    func test_State_Disabled_With_Text() {
        // Given
        let state = CustomToolbarState.disabledWithText("Test")

        // When
        sut.state = state

        // Then
        XCTAssertNotNil(sut.primaryButton)
        XCTAssertEqual(sut.primaryButton.text, "Test")
        XCTAssertEqual(sut.primaryButton.buttonBackgroundColor, UIConstants.BrandColor.onBackground20)
        XCTAssertEqual(sut.primaryButton.buttonTextColor, UIConstants.BrandColor.onBackground50)
        XCTAssertEqual(sut.primaryButton.shadowColor, .clear)
        XCTAssertEqual(sut.primaryButton.cornerRadius, UIConstants.Size.ButtonCornerRadius)
        XCTAssertFalse(sut.primaryButton.isEnabled)
    }

    func test_State_Disabled() {
        // Given
        let state = CustomToolbarState.disabled

        // When
        sut.state = state

        // Then
        XCTAssertNotNil(sut.primaryButton)
        XCTAssertEqual(sut.primaryButton.buttonBackgroundColor, UIConstants.BrandColor.onBackground20)
        XCTAssertEqual(sut.primaryButton.buttonTextColor, UIConstants.BrandColor.onBackground50)
        XCTAssertEqual(sut.primaryButton.shadowColor, .clear)
        XCTAssertEqual(sut.primaryButton.cornerRadius, UIConstants.Size.ButtonCornerRadius)
        XCTAssertFalse(sut.primaryButton.isEnabled)
    }

    func testSettingPrimaryButton() {
        // When
        sut.primaryButton = MainButton()
        // Then
        XCTAssertEqual(sut.primaryButton.textableView.numberOfLines, 2)
        XCTAssertEqual(sut.primaryButton.innerButton.titleLabel?.numberOfLines, 2)
    }

    func testVoiceOver() {
        sut.state = .confirm("OK")

        sut.primaryButtonVoiceOverSettings = VoiceOverOptions.Settings()
        sut.leftButtonVoiceOverSettings = VoiceOverOptions.Settings()

        sut.primaryButtonVoiceOverSettings?.label = "primaryLabel"
        sut.primaryButtonVoiceOverSettings?.hint = "primaryHint"
        sut.primaryButtonVoiceOverSettings?.traits = [.button,
                                                      .notEnabled]

        sut.leftButtonVoiceOverSettings?.label = "leftLabel"
        sut.leftButtonVoiceOverSettings?.hint = "leftHint"
        sut.leftButtonVoiceOverSettings?.traits = [.button,
                                                   .updatesFrequently]

        XCTAssertEqual(sut.primaryButton.textableView.accessibilityLabel, "primaryLabel")
        XCTAssertEqual(sut.primaryButton.textableView.accessibilityHint, "primaryHint")
        XCTAssertEqual(sut.primaryButton.textableView.accessibilityTraits, [UIAccessibilityTraits.button,
                                                                            UIAccessibilityTraits.notEnabled])

        XCTAssertEqual(sut.leftButton.accessibilityLabel, "leftLabel")
        XCTAssertEqual(sut.leftButton.accessibilityHint, "leftHint")
        XCTAssertEqual(sut.leftButton.accessibilityTraits, [UIAccessibilityTraits.button,
                                                            UIAccessibilityTraits.updatesFrequently])
    }
}
