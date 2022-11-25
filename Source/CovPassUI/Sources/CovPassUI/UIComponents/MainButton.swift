//
//  MainButton.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class MainButton: XibView {
    // MARK: - IBOutlet

    @IBOutlet public var innerButton: UIButton!
    @IBOutlet var dotPulseActivityView: DotPulseActivityIndicator!

    // MARK: - Properties

    public var style: MainButtonStyle = .primary {
        didSet {
            updateTextStyle()
            updateAppearence()
            setupActivityIndicatorView()
        }
    }

    public var title: String? {
        didSet {
            updateTextStyle()
            updateAppearence()
        }
    }

    public var icon: UIImage? {
        didSet {
            innerButton.setImage(icon, for: .normal)
            enableAccessibility(label: icon?.accessibilityLabel,
                                traits: icon?.accessibilityTraits)
            updateAppearence()
        }
    }

    var buttonWidthConstraint: NSLayoutConstraint?
    var buttonHeightConstraint: NSLayoutConstraint?
    private let animationDuration: TimeInterval = 0.2

    public var isEnabled: Bool {
        get { innerButton.isEnabled }
        set {
            innerButton.isEnabled = newValue
            updateAppearence()
        }
    }

    public var action: (() -> Void)?
    private var observerTokens = [NSKeyValueObservation?]()

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()

        contentMode = .center
        backgroundColor = .clear
        contentView?.backgroundColor = .clear
        contentView?.layoutMargins = .zero

        setupShadow()
        setupInnerButton()
        setupActivityIndicatorView()
        setupConstraints()
        setupObservers()
        updateAppearence()
        isAccessibilityElement = true
        if #available(iOS 13.0, *) {
            accessibilityRespondsToUserInteraction = true
        }
    }

    deinit {
        observerTokens.forEach { $0?.invalidate() }
    }

    private func setupShadow() {
        layer.shadowRadius = 9
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
        layer.borderWidth = 1
        layer.shadowOffset = .init(width: 0, height: 0.3)
    }

    private func setupInnerButton() {
        innerButton.titleLabel?.numberOfLines = 0
        innerButton.titleLabel?.adjustsFontForContentSizeCategory = true
        innerButton.imageView?.contentMode = .scaleAspectFit
        innerButton.accessibilityIdentifier = AccessibilityIdentifier.TimeLine.serviceSelectionButton
        let maxButtonWidth = UIScreen.main.bounds.width - 2 * .space_24
        innerButton.widthAnchor.constraint(lessThanOrEqualToConstant: maxButtonWidth).isActive = true
    }

    private func setupActivityIndicatorView() {
        dotPulseActivityView.numberOfDots = 3
        dotPulseActivityView.color = style == .primary ? .backgroundSecondary : .brandAccent
        dotPulseActivityView.padding = 5
    }

    func setupConstraints() {
        // Constraints for circle button
        let size: CGFloat = 56
        buttonHeightConstraint = heightAnchor.constraint(equalToConstant: size)
        buttonWidthConstraint = widthAnchor.constraint(equalToConstant: size)
    }

    func setupObservers() {
        // Observe state changes and update appearance
        let keys = [\UIButton.isHighlighted, \UIButton.isSelected, \UIButton.isEnabled]
        keys.forEach {
            observerTokens.append(
                innerButton.observe($0) { [weak self] _, _ in
                    self?.updateAppearence()
                }
            )
        }
    }

    // MARK: - Methods

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateAppearence()
    }

    /// Animating
    public func startAnimating(makeCircle: Bool = true) {
        if makeCircle {
            [buttonWidthConstraint, buttonHeightConstraint].forEach { $0?.isActive = true }
            innerButton.contentEdgeInsets = .zero
        }
        innerButton.alpha = 0
        dotPulseActivityView.startAnimating()
    }

    public func stopAnimating() {
        dotPulseActivityView.stopAnimating()
        innerButton.alpha = 1
        [buttonWidthConstraint, buttonHeightConstraint].forEach { $0?.isActive = false }
        updateAppearence()
    }

    /// Enables the button and changes the background color to enabled color.
    public func enable() {
        isEnabled = true
        setNeedsLayout()
        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
        }
    }

    /// Disables the button and changes the background color to disabled color.
    public func disable() {
        isEnabled = false
        setNeedsLayout()
        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
        }
    }

    @IBAction func buttonPressed() {
        action?()
    }

    private func updateTextStyle() {
        let attributedText = title?.styledAs(.mainButton).aligned(to: .center)
        innerButton.setAttributedTitle(attributedText?.colored(style.textColor), for: .normal)
        innerButton.setAttributedTitle(attributedText?.colored(style.disabledTextColor), for: .disabled)
        innerButton.setAttributedTitle(attributedText?.colored(style.highlightedTextColor), for: .highlighted)
        enableAccessibility(label: title, traits: .button)
    }

    private func updateAppearence() {
        updateBackgroundColor()
        updateLayer()
        updateInsets()
        updateShadow()
    }

    private func updateBackgroundColor() {
        switch innerButton.state {
        case .normal:
            backgroundColor = style.backgroundColor
        case .selected:
            backgroundColor = style.selectedBackgroundColor
        case .highlighted:
            backgroundColor = style.highlightedBackgroundColor
        case .disabled:
            backgroundColor = style.disabledBackgroundColor
        default:
            break
        }
    }

    private func updateLayer() {
        switch innerButton.state {
        case .normal:
            layer.borderColor = style.borderColor?.cgColor
        case .selected:
            layer.borderColor = style.selectedBorderColor?.cgColor
        case .highlighted:
            layer.borderColor = style.highlightedBorderColor?.cgColor
        case .disabled:
            layer.borderColor = style.disabledBorderColor?.cgColor
        default:
            break
        }

        layer.cornerRadius = style == .invisible ? 0 : bounds.height / 2
    }

    private func updateShadow() {
        switch innerButton.state {
        case .disabled:
            layer.shadowColor = style.disabledShadowColor?.cgColor
        default:
            layer.shadowColor = style.shadowColor?.cgColor
        }
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    private func updateInsets() {
        switch (icon != nil, title.isNilOrEmpty == false) {
        case (true, false):
            // icon only
            innerButton.contentEdgeInsets = UIEdgeInsets(top: .space_10, left: .space_10, bottom: .space_10, right: .space_10)
            innerButton.titleEdgeInsets = .zero

        case (false, true):
            // text only
            innerButton.contentEdgeInsets = UIEdgeInsets(top: .space_18, left: .space_40, bottom: .space_18, right: .space_40)
            innerButton.titleEdgeInsets = .zero

        case (true, true):
            // icon and text
            let distance: CGFloat = .space_8
            innerButton.contentEdgeInsets = UIEdgeInsets(top: .space_18, left: .space_40, bottom: .space_18, right: .space_40 + distance)
            innerButton.titleEdgeInsets.right = -distance
            innerButton.titleEdgeInsets.left = distance

        default:
            break
        }
    }

    override public func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        updateFocusBorderView()
    }
}
