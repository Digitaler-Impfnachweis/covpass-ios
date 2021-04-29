//
//  MainButton.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

@IBDesignable
/// A custom button with support for rounded corners, shadow and animation
public class MainButton: XibView {

    @IBOutlet public var innerButton: UIButton!
    @IBOutlet var dotPulseActivityView: DotPulseActivityIndicator!

    public var style: MainButtonStyle = .primary {
        didSet {
            updateTextStyle()
            updateAppearence()
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
            updateAppearence()
        }
    }

    var buttonWidthConstraint: NSLayoutConstraint?
    var buttonHeightConstraint: NSLayoutConstraint?
    private let animationDuration: TimeInterval = 0.2

    public var isEnabled: Bool {
        get { innerButton.isEnabled }
        set { innerButton.isEnabled = newValue }
    }

    public var action: (() -> Void)?
    private var observerTokens = [NSKeyValueObservation?]()

    // MARK: - Lifecycle

    public override func initView() {
        super.initView()

        contentView?.layoutMargins = .zero

        // Shadow
        layer.shadowRadius = UIConstants.Size.ButtonShadowRadius
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
        layer.borderWidth = 2
        layer.shadowOffset = .init(width: 0, height: 0.3)

        innerButton.titleLabel?.adjustsFontForContentSizeCategory = true
        innerButton.accessibilityIdentifier = AccessibilityIdentifier.TimeLine.serviceSelectionButton
        contentMode = .center

        // Background
        backgroundColor = .clear
        contentView?.backgroundColor = .clear

        // Dot Pulse Animation
        dotPulseActivityView.numberOfDots = UIConstants.Animation.DotPulseAnimationDotsNumber
        dotPulseActivityView.color = UIConstants.BrandColor.backgroundSecondary
        dotPulseActivityView.padding = UIConstants.Size.ButtonDotPulseAnimationPadding

        updateAppearence()

        let maxButtonWidth = UIScreen.main.bounds.width - 2 * UIConstants.Size.PrimaryButtonMargin
        innerButton.widthAnchor.constraint(lessThanOrEqualToConstant: maxButtonWidth).isActive = true

        // Constraints for circle button
        buttonHeightConstraint = heightAnchor.constraint(equalToConstant: UIConstants.Size.ButtonAnimatingSize)
        buttonWidthConstraint = widthAnchor.constraint(equalToConstant: UIConstants.Size.ButtonAnimatingSize)

        let keys = [\UIButton.isHighlighted, \UIButton.isSelected, \UIButton.isEnabled]

        keys.forEach {
            observerTokens.append(
                innerButton.observe($0) { [weak self] (_, _) in
                    self?.updateAppearence()
                }
            )
        }
    }

    deinit {
        observerTokens.forEach { $0?.invalidate() }
    }

    // MARK: - Methods

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateAppearence()
    }

    /// Animating
    public func startAnimating(makeCircle: Bool = true) {
        if makeCircle {
            [buttonWidthConstraint, buttonHeightConstraint].forEach({ $0?.isActive = true })
            innerButton.contentEdgeInsets = .zero
        }
        innerButton.alpha = 0
        dotPulseActivityView.startAnimating()
    }

    public func stopAnimating() {
        dotPulseActivityView.stopAnimating()
        innerButton.alpha = 1
        [buttonWidthConstraint, buttonHeightConstraint].forEach({ $0?.isActive = false })
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

    @IBAction func buttonPressed(_: Any) {
        action?()
    }

    private func updateTextStyle() {
        let attributedText = title?.toAttributedString(.mainButton).aligned(to: .center)
        innerButton.setAttributedTitle(attributedText?.colored(style.textColor), for: .normal)
        innerButton.setAttributedTitle(attributedText?.colored(style.disabledTextColor), for: .disabled)
        innerButton.setAttributedTitle(attributedText?.colored(style.highlightedTextColor), for: .highlighted)
    }

    private func updateAppearence() {
        updateBackgroundColor()
        updateLayer()
        updateInsets()
    }

    private func updateBackgroundColor() {
        switch innerButton.state {
        case .normal:
            backgroundColor = style.backgroundColor
        case .selected:
            backgroundColor = style.selectedBackgroundColor
        case .highlighted:
            backgroundColor = style.highlightedBackgroundColor
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
        default:
            break
        }

        layer.cornerRadius = bounds.height / 2
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shadowColor = style.shadowColor?.cgColor
    }

    private func updateInsets() {
        switch (icon == nil, title.isNilOrEmpty) {
        case (true, false):
            // text only
            innerButton.contentEdgeInsets = UIEdgeInsets(top: .space_18, left: .space_40, bottom: .space_18, right: .space_40)
            innerButton.titleEdgeInsets = .zero

        case (false, true):
            // icon only
            innerButton.contentEdgeInsets = UIEdgeInsets(top: .space_10, left: .space_10, bottom: .space_10, right: .space_10)
            innerButton.titleEdgeInsets = .zero

        case (false, false):
            // icon and text
            let distance: CGFloat = .space_8
            innerButton.contentEdgeInsets = UIEdgeInsets(top: .space_18, left: .space_40, bottom: .space_18, right: .space_40 + distance)
            innerButton.titleEdgeInsets.right = -distance
            innerButton.titleEdgeInsets.left = distance
        default:
            break
        }
    }
}
