//
//  CustomToolbarView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

private enum Constants {
    enum Layout {
        static let cancelButtonWidth: CGFloat = 54
        static let cancelButtonHeight: CGFloat = 54
    }

    enum Accessibility {
        static let back = VoiceOverOptions.Settings(label: "accessibility_onboarding_pages_label_back".localized)
        static let scrollToBottom = VoiceOverOptions.Settings(label: "accessibility_fourth_onboarding_page_label_scroll_to_end".localized)
    }
}

public protocol CustomToolbarViewDelegate: AnyObject {
    func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType)
}

public enum ButtonItemType {
    case navigationArrow
    case cancelButton
    case checkButton
    case addButton
    case textButton
    case disabledTextButton
    case progressActivity
    case scrollButton
    case disabledWithText
    case flashLight
}

public enum CustomToolbarState: Equatable {
    case none
    case cancel
    case done
    case inProgress
    case scrollAware
    case confirm(String)
    case disabled
    case disabledWithText(String)
    case flashLight
}

/// A custom toolbar that supports multiple states
public class CustomToolbarView: XibView {
    public weak var delegate: CustomToolbarViewDelegate?

    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    public var primaryButton: MainButton!

    public var state: CustomToolbarState {
        get {
            .cancel
        }
        set {
            switch newValue {
            case .none:
                resetPrimaryButton()
            case .cancel:
                setUpMiddleButton(middleButtonItem: .cancelButton)
            case .done:
                setUpMiddleButton(middleButtonItem: .checkButton)
            case .inProgress:
                setUpMiddleButton(middleButtonItem: .progressActivity)
            case .scrollAware:
                setUpMiddleButton(middleButtonItem: .scrollButton)
            case let .confirm(title):
                setupMiddleButton(with: title)
            case .disabled:
                setupDisabledButton()
            case let .disabledWithText(title):
                setupDisabledButton(with: title)
            case .flashLight:
                setUpRightButton(rightButtonItem: .flashLight)
            }
        }
    }

    public var leftButtonVoiceOverSettings: VoiceOverOptions.Settings? {
        didSet {
            leftButtonVoiceOverSettings.map {
                leftButton.enableAccessibility(label: $0.label,
                                               hint: $0.hint,
                                               traits: $0.traits)
            }
        }
    }

    public var primaryButtonVoiceOverSettings: VoiceOverOptions.Settings? {
        didSet {
            primaryButtonVoiceOverSettings.map {
                primaryButton.innerButton.enableAccessibility(label: $0.label,
                                                              hint: $0.hint,
                                                              traits: $0.traits)
            }
        }
    }

    public var rightButtonVoiceOverSettings: VoiceOverOptions.Settings? {
        didSet {
            rightButtonVoiceOverSettings.map {
                rightButton.enableAccessibility(label: $0.label,
                                                hint: $0.hint,
                                                traits: $0.traits)
            }
        }
    }

    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?

    public func setUpLeftButton(leftButtonItem: ButtonItemType?) {
        guard let leftButtonItem = leftButtonItem else {
            resetSecondary(button: leftButton)
            return
        }

        leftButton.isHidden = false
        leftButton.isEnabled = true
        leftButton.tintColor = .onBackground70
        switch leftButtonItem {
        case .navigationArrow:
            leftButton.setImage(.arrowBack, for: .normal)
            leftButtonAction = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.customToolbarView(strongSelf, didTap: .navigationArrow)
            }
            leftButton.enableAccessibility(label: Constants.Accessibility.back.label)
        default:
            resetSecondary(button: leftButton)
        }
    }

    public func setUpRightButton(rightButtonItem: ButtonItemType?) {
        if case .flashLight = rightButtonItem {
            rightButton.isHidden = false
            enableRightButton(rightButtonItem: rightButtonItem)
            rightButton.setImage(.flashOff, for: .normal)
            rightButton.setImage(.flashOn, for: .selected)

            rightButtonAction = { [weak self] in
                guard let self = self else { return }
                self.rightButton.isSelected.toggle()
                self.delegate?.customToolbarView(self, didTap: .flashLight)
            }
        }
    }

    public func disableRightButton(rightButtonItem: ButtonItemType?) {
        if case .flashLight = rightButtonItem {
            rightButton.isEnabled = false
        }
    }

    public func enableRightButton(rightButtonItem: ButtonItemType?) {
        if case .flashLight = rightButtonItem {
            rightButton.isEnabled = true
        }
    }

    private func setupMiddleButton(with text: String) {
        resetPrimaryButton()
        configureMiddleButton(button: textButton, title: text)
    }

    private func setupDisabledButton(with text: String? = nil) {
        resetPrimaryButton()
        configureDisabledButton(button: disabledButtonWithText, title: text)
    }

    public func setUpMiddleButton(middleButtonItem: ButtonItemType?) {
        let previousMiddleButton = primaryButton
        resetPrimaryButton()
        guard let middleButtonItem = middleButtonItem else { return }

        switch middleButtonItem {
        case .cancelButton:
            configureCancelButton(button: cancelButton)
        case .textButton:
            configureMiddleButton(button: textButton)
        case .disabledTextButton:
            configureMiddleButton(button: disabledTextButton)
        case .addButton:
            configureMiddleButton(button: addButton)
        case .checkButton:
            configureMiddleButton(button: checkButton)
        case .progressActivity:
            configureLoadingButton(previousMiddleButton: previousMiddleButton)
        case .scrollButton:
            configureScrollButton(button: scrollButton)
        default:
            break
        }
    }

    private var cancelButton: MainButton {
        primaryButton = MainButton()
        primaryButton.style = .tertiary
        primaryButton.icon = .cancel
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .cancelButton)
        }
        NSLayoutConstraint.activate([
            primaryButton.heightAnchor.constraint(equalToConstant: Constants.Layout.cancelButtonHeight),
            primaryButton.widthAnchor.constraint(equalToConstant: Constants.Layout.cancelButtonWidth)
        ])
        return primaryButton
    }

    private var textButton: MainButton {
        primaryButton = MainButton()
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .textButton)
        }
        return primaryButton
    }

    private var disabledButtonWithText: MainButton {
        primaryButton = MainButton()
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .disabledWithText)
        }
        return primaryButton
    }

    private var disabledTextButton: MainButton {
        primaryButton = MainButton()
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .textButton)
        }
        return primaryButton
    }

    private var addButton: MainButton {
        primaryButton = MainButton()
        primaryButton.icon = .plus
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .addButton)
        }
        return primaryButton
    }

    private var checkButton: MainButton {
        primaryButton = MainButton()
        primaryButton.icon = .check
        primaryButton.innerButton.accessibilityIdentifier = AccessibilityIdentifier.InputForms.checkButton
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .checkButton)
        }
        return primaryButton
    }

    private var scrollButton: MainButton {
        primaryButton = MainButton()
        primaryButton.icon = .arrowDown
        primaryButton.innerButton.tintColor = .backgroundSecondary
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .scrollButton)
        }
        enableAccessibility(label: Constants.Accessibility.scrollToBottom.label)
        NSLayoutConstraint.activate([
            primaryButton.heightAnchor.constraint(equalToConstant: Constants.Layout.cancelButtonHeight),
            primaryButton.widthAnchor.constraint(equalToConstant: Constants.Layout.cancelButtonWidth)
        ])
        return primaryButton
    }

    private func configureLoadingButton(previousMiddleButton: MainButton?) {
        var showLoadingOverIconButton = true
        if let primaryButton = previousMiddleButton, !primaryButton.title.isNilOrEmpty {
            showLoadingOverIconButton = false
        }
        let title = showLoadingOverIconButton == false ? previousMiddleButton?.title : nil
        primaryButton = showLoadingOverIconButton ? MainButton() : previousMiddleButton
        primaryButton.startAnimating(makeCircle: showLoadingOverIconButton)
        configureMiddleButton(button: primaryButton, title: title)
    }

    // MARK: Private Methods

    private func resetSecondary(button: UIButton) {
        button.isHidden = true
        button.isEnabled = false
    }

    private func resetPrimaryButton() {
        primaryButton?.removeFromSuperview()
        primaryButton = nil
    }

    private func configureCancelButton(button: MainButton) {
        button.tintColor = .onBackground70
        addSubview(button)
        configureCenterConstraints(for: button)
    }

    private func configureDisabledButton(button: MainButton, title: String? = nil) {
        button.isEnabled = false
        button.title = title
        addSubview(button)
        configureCenterConstraints(for: button)
    }

    private func configureMiddleButton(button: MainButton, title: String? = nil) {
        button.title = title
        addSubview(button)
        configureCenterConstraints(for: button)
    }

    private func configureScrollButton(button: MainButton) {
        addSubview(button)
        configureCenterConstraints(for: button)
    }

    private func configureCenterConstraints(for button: MainButton) {
        button.centerX(of: layoutMarginsGuide)
        button.pinEdges([.top, .bottom], to: layoutMarginsGuide)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
    }

    // MARK: Action Methods

    @IBAction func leftButtonPressed() {
        leftButtonAction?()
    }

    @IBAction func didTouchRightButton() {
        rightButtonAction?()
    }
}

public extension CustomToolbarView {
    override var accessibilityElements: [Any]? {
        get {
            [primaryButton as Any, leftButton as Any, rightButton as Any]
        }
        set {}
    }
}
