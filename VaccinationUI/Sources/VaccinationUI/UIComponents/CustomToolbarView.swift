//
//  CustomToolbarView.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol CustomToolbarViewDelegate: AnyObject {
    func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType)
}

struct ToolBarItems {
    var leftItem: ButtonItemType?
    var middleItem: ButtonItemType?
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
}

/// A custom toolbar that supports multiple states
@IBDesignable
public class CustomToolbarView: XibView {
    public weak var delegate: CustomToolbarViewDelegate?

    @IBOutlet var leftButton: UIButton!
    @IBOutlet var gradientImageView: UIImageView!

    @IBInspectable var navigationIcon: String = UIConstants.IconName.NavigationArrow
    @IBInspectable var navigationIconColor: UIColor = UIConstants.BrandColor.onBackground70

    public var primaryButton: MainButton! {
        didSet {
            primaryButton?.innerButton.titleLabel?.numberOfLines = 2
        }
    }

    var state: CustomToolbarState {
        get {
            return .cancel
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
            }
        }
    }

    public var shouldShowTransparency: Bool = true {
        didSet {
            backgroundColor = shouldShowTransparency ? UIColor.clear : UIColor.white
        }
    }
    
    public var shouldShowGradient: Bool = false {
        didSet {
            gradientImageView.isHidden = !shouldShowTransparency
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

    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?

    public func setUpLeftButton(leftButtonItem: ButtonItemType?) {
        guard let leftButtonItem = leftButtonItem else {
            resetSecondary(button: leftButton)
            return
        }

        leftButton.isHidden = false
        leftButton.isEnabled = true
        switch leftButtonItem {
        case .navigationArrow:
            leftButton.setImage(UIImage(named: navigationIcon, in: UIConstants.bundle, compatibleWith: nil)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            leftButton.tintColor = navigationIconColor
            leftButtonAction = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.customToolbarView(strongSelf, didTap: .navigationArrow)
            }
        default:
            resetSecondary(button: leftButton)
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
        let cancelIcon = UIImage(named: UIConstants.IconName.CancelButton, in: UIConstants.bundle, compatibleWith: nil)
        primaryButton = MainButton()
        primaryButton.icon = cancelIcon
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .cancelButton)
        }
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
        let plusIcon = UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil)
        primaryButton = MainButton()
        primaryButton.icon = plusIcon
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .addButton)
        }
        return primaryButton
    }

    private var checkButton: MainButton {
        let checkmarkIcon = UIImage(named: UIConstants.IconName.CheckmarkIcon, in: UIConstants.bundle, compatibleWith: nil)
        primaryButton = MainButton()
        primaryButton.icon = checkmarkIcon
        primaryButton.innerButton.accessibilityIdentifier = AccessibilityIdentifier.InputForms.checkButton
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .checkButton)
        }
        return primaryButton
    }

    private var scrollButton: MainButton {
        let arrowIcon = UIImage(named: UIConstants.IconName.RgArrowDown, in: UIConstants.bundle, compatibleWith: nil)
        primaryButton = MainButton()
        primaryButton.icon = arrowIcon
        primaryButton.tintColor = navigationIconColor
        primaryButton.innerButton.accessibilityIdentifier = AccessibilityIdentifier.InputForms.scrollButton
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .scrollButton)
        }
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
        button.layer.shadowOpacity = 0
        button.tintColor = UIConstants.BrandColor.onBackground70

        addSubview(button)
        configureDefaultConstraints(for: button)
    }

    private func configureDisabledButton(button: MainButton, title: String? = nil) {
        button.isEnabled = false

        addSubview(button)
        configureDefaultConstraints(for: button)
    }

    private func configureMiddleButton(button: MainButton, title: String? = nil) {
        button.title = title
        addSubview(button)
        configureDefaultConstraints(for: button)
    }

    private func configureScrollButton(button: MainButton) {
        addSubview(button)
        configureDefaultConstraints(for: button)
    }

    private func configureDefaultConstraints(for button: MainButton) {
        button.centerX(of: layoutMarginsGuide)
        button.pinEdges([.top, .bottom], to: layoutMarginsGuide)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
    }

    // MARK: Action Methods

    @IBAction func leftButtonPressed(_: Any) {
        leftButtonAction?()
    }
}
