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

    public var primaryButton: PrimaryButtonContainer! {
        didSet {
            primaryButton?.textableView.numberOfLines = 2
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
                primaryButton.textableView.enableAccessibility(label: $0.label,
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

    private var cancelButton: PrimaryButtonContainer {
        let cancelIcon = UIImage(named: UIConstants.IconName.CancelButton, in: UIConstants.bundle, compatibleWith: nil)
        primaryButton = PrimaryIconButtonContainer(iconImage: cancelIcon, iconHeightMultiplier: 0.6)
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .cancelButton)
        }
        return primaryButton
    }

    private var textButton: PrimaryButtonContainer {
        primaryButton = PrimaryButtonContainer()
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .textButton)
        }
        return primaryButton
    }

    private var disabledButtonWithText: PrimaryButtonContainer {
        primaryButton = PrimaryButtonContainer()
        primaryButton.enabledButtonBackgroundColor = UIConstants.BrandColor.onBackground20
        primaryButton.enabledButtonTextColor = UIConstants.BrandColor.onBackground50
        primaryButton.shadowColor = UIColor.clear
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .disabledWithText)
        }
        return primaryButton
    }

    private var disabledTextButton: PrimaryButtonContainer {
        primaryButton = PrimaryButtonContainer()
        primaryButton.enabledButtonBackgroundColor = UIConstants.BrandColor.onBackground20
        primaryButton.shadowColor = UIColor.clear
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .textButton)
        }
        return primaryButton
    }

    private var addButton: PrimaryButtonContainer {
        let plusIcon = UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil)
        primaryButton = PrimaryIconButtonContainer(iconImage: plusIcon, iconHeightMultiplier: 0.6)
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .addButton)
        }
        return primaryButton
    }

    private var checkButton: PrimaryButtonContainer {
        let checkmarkIcon = UIImage(named: UIConstants.IconName.CheckmarkIcon, in: UIConstants.bundle, compatibleWith: nil)
        primaryButton = PrimaryIconButtonContainer(iconImage: checkmarkIcon, iconHeightMultiplier: 0.6)
        primaryButton.innerButton.accessibilityIdentifier = AccessibilityIdentifier.InputForms.checkButton
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .checkButton)
        }
        return primaryButton
    }

    private var scrollButton: PrimaryButtonContainer {
        let arrowIcon = UIImage(named: UIConstants.IconName.RgArrowDown, in: UIConstants.bundle, compatibleWith: nil)
        primaryButton = PrimaryIconButtonContainer(iconImage: arrowIcon, iconHeightMultiplier: 0.6)
        primaryButton.tintColor = navigationIconColor
        primaryButton.enabledButtonBackgroundColor = UIColor.clear
        primaryButton.innerButton.accessibilityIdentifier = AccessibilityIdentifier.InputForms.scrollButton
        primaryButton.action = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.customToolbarView(strongSelf, didTap: .scrollButton)
        }
        return primaryButton
    }

    private func configureLoadingButton(previousMiddleButton: PrimaryButtonContainer?) {
        var showLoadingOverIconButton = true
        if let primaryButton = previousMiddleButton, !primaryButton.title.isEmpty {
            showLoadingOverIconButton = false
        }
        primaryButton = showLoadingOverIconButton ? PrimaryButtonContainer() : previousMiddleButton
        primaryButton.startAnimating(makeCircle: showLoadingOverIconButton)
        configureMiddleButton(button: primaryButton)
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

    private func configureCancelButton(button: PrimaryButtonContainer) {
        button.layer.shadowOpacity = 0
        button.cornerRadius = UIConstants.Size.ButtonCornerRadius
        button.enabledButtonBackgroundColor = UIConstants.BrandColor.onBackground20
        button.tintColor = UIConstants.BrandColor.onBackground70

        addSubview(button)
        button.centerX(of: self)
        button.centerY(of: self)
        button.setConstant(height: UIConstants.Size.CancelButtonSize)
        button.setConstant(width: UIConstants.Size.CancelButtonSize)
    }

    private func configureDisabledButton(button: PrimaryButtonContainer, title: String? = nil) {
        button.cornerRadius = UIConstants.Size.ButtonCornerRadius
        button.defaultText = title
        button.isEnabled = false

        addSubview(button)
        button.centerX(of: self)
        button.centerY(of: self)
        if button is PrimaryIconButtonContainer {
            button.setConstant(height: UIConstants.Size.MiddleButtonSize)
            button.setConstant(width: UIConstants.Size.MiddleButtonSize)
        }
    }

    private func configureMiddleButton(button: PrimaryButtonContainer, title: String? = nil) {
        button.cornerRadius = UIConstants.Size.ButtonCornerRadius
        button.shadowColor = UIConstants.BrandColor.primaryButtonShadow
        addSubview(button)
        button.centerX(of: self)
        button.centerY(of: self)
        if button is PrimaryIconButtonContainer {
            button.setConstant(height: UIConstants.Size.MiddleButtonSize)
            button.setConstant(width: UIConstants.Size.MiddleButtonSize)
        }
        button.defaultText = title
    }

    private func configureScrollButton(button: PrimaryButtonContainer) {
        button.cornerRadius = UIConstants.Size.ButtonCornerRadius
        button.shadowColor = UIColor.clear

        addSubview(button)
        button.centerX(of: self)
        button.centerY(of: self)
        if button is PrimaryIconButtonContainer {
            button.setConstant(height: UIConstants.Size.MiddleButtonSize)
            button.setConstant(width: UIConstants.Size.MiddleButtonSize)
        }
    }

    // MARK: Action Methods

    @IBAction func leftButtonPressed(_: Any) {
        leftButtonAction?()
    }
}
