//
//  CustomToolbarViewTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
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
    }

    func testSetup() {
        sut.setUpLeftButton(leftButtonItem: .navigationArrow)
        XCTAssertFalse(sut.leftButton.isHidden)
        XCTAssertTrue(sut.leftButton.isEnabled)
        XCTAssertEqual(sut.leftButton.tintColor, .onBackground70)

        sut.setUpLeftButton(leftButtonItem: nil)
        XCTAssertEqual(sut.leftButton.isEnabled, false)

        sut.setUpMiddleButton(middleButtonItem: .cancelButton)
        XCTAssertTrue(sut.subviews.last is MainButton)
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
        XCTAssertTrue(sut.primaryButton.isEnabled)

        XCTAssertEqual(sut.primaryButton.tintColor, .onBackground70)
    }

    func test_State_Check() {
        // Given
        let state = CustomToolbarState.done

        // When
        sut.state = state

        // Then
        XCTAssertNotNil(sut.primaryButton)
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
        XCTAssertTrue(sut.primaryButton.isEnabled)
    }

    func test_State_Disabled_With_Text() {
        // Given
        let state = CustomToolbarState.disabledWithText("Test")

        // When
        sut.state = state

        // Then
        XCTAssertNotNil(sut.primaryButton)
        XCTAssertEqual(sut.primaryButton.title, "Test")
        XCTAssertEqual(sut.primaryButton.style, .primary)
        XCTAssertFalse(sut.primaryButton.isEnabled)
    }

    func test_State_Disabled() {
        // Given
        let state = CustomToolbarState.disabled

        // When
        sut.state = state

        // Then
        XCTAssertNotNil(sut.primaryButton)
        XCTAssertEqual(sut.primaryButton.style, .primary)
        XCTAssertFalse(sut.primaryButton.isEnabled)
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

        XCTAssertEqual(sut.primaryButton.innerButton.accessibilityLabel, "primaryLabel")
        XCTAssertEqual(sut.primaryButton.innerButton.accessibilityHint, "primaryHint")
        XCTAssertEqual(sut.primaryButton.innerButton.accessibilityTraits, [UIAccessibilityTraits.button,
                                                                           UIAccessibilityTraits.notEnabled])

        XCTAssertEqual(sut.leftButton.accessibilityLabel, "leftLabel")
        XCTAssertEqual(sut.leftButton.accessibilityHint, "leftHint")
        XCTAssertEqual(sut.leftButton.accessibilityTraits, [UIAccessibilityTraits.button,
                                                            UIAccessibilityTraits.updatesFrequently])
    }

    func testDisableLeftButton() {
        // When
        sut.disableLeftButton()

        // Then
        XCTAssertTrue(sut.leftButton.isHidden)
    }

    func testDisableRightButton() {
        // When
        sut.disableRightButton()

        // Then
        XCTAssertTrue(sut.rightButton.isHidden)
    }

    func testAccessibilityElements() throws {
        // When
        sut.state = .done
        let elements = try XCTUnwrap(sut.accessibilityElements)

        // Then
        XCTAssertEqual(elements.count, 3)
        XCTAssertTrue(elements.contains(sut.leftButton))
        XCTAssertTrue(elements.contains(sut.rightButton))
        XCTAssertTrue(elements.contains(sut.primaryButton))
    }

    func testAccessibilityElements_left_button_hidden() throws {
        // Given
        sut.state = .done
        sut.leftButton.isHidden = true

        // When
        let elements = try XCTUnwrap(sut.accessibilityElements)

        // Then
        XCTAssertEqual(elements.count, 2)
        XCTAssertFalse(elements.contains(sut.leftButton))
    }

    func testAccessibilityElements_right_button_hidden() throws {
        // Given
        sut.state = .done
        sut.rightButton.isHidden = true

        // When
        let elements = try XCTUnwrap(sut.accessibilityElements)

        // Then
        XCTAssertEqual(elements.count, 2)
        XCTAssertFalse(elements.contains(sut.rightButton))
    }

    func testAccessibilityElements_primary_button_hidden() throws {
        // When
        let elements = try XCTUnwrap(sut.accessibilityElements)

        // Then
        XCTAssertFalse(elements.contains(sut.primaryButton))
    }

    func testAccessibilityElements_all_buttons_hidden() throws {
        // Given
        sut.state = .done
        sut.primaryButton.isHidden = true
        sut.leftButton.isHidden = true
        sut.rightButton.isHidden = true

        // When
        let elements = try XCTUnwrap(sut.accessibilityElements)

        // Then
        XCTAssertTrue(elements.isEmpty)
    }
}

private extension Array where Element == Any {
    func contains<Button: Equatable>(_ button: Button) -> Bool {
        contains { element in
            if let elementButton = element as? Button {
                return elementButton == button
            } else {
                return false
            }
        }
    }
}
