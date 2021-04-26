//
//  PrimaryButtonContainer.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

@IBDesignable
/// A custom button with support for rounded corners, shadow and animation
public class PrimaryButtonContainer: XibView, Textable {
    @IBOutlet var dotPulseActivityView: DotPulseActivityIndicator!

    @IBOutlet public var textableView: UILabel!
    @IBOutlet public var innerButton: UIButton!

    var buttonWidthConstraint: NSLayoutConstraint?
    var buttonHeightConstraint: NSLayoutConstraint?
    private let animationDuration: TimeInterval = 0.2

    /// For backward compatibility with PrimaryButtonContainer
    public var buttonBackgroundColor: UIColor {
        get { enabledButtonBackgroundColor }
        set { enabledButtonBackgroundColor = newValue }
    }

    /// For backward compatibility with PrimaryButtonContainer
    public var buttonTextColor: UIColor {
        get { enabledButtonTextColor }
        set { enabledButtonTextColor = newValue }
    }

    // MARK: - IBInspectable

    @IBInspectable public var enabledButtonBackgroundColor: UIColor = UIConstants.BrandColor.brandAccent {
        didSet { updateAppearence() }
    }

    @IBInspectable public var disabledButtonBackgroundColor: UIColor = UIConstants.BrandColor.onBackground20 {
        didSet { updateAppearence() }
    }

    @IBInspectable public var enabledButtonTextColor: UIColor = UIConstants.BrandColor.onBrandAccent {
        didSet { updateAppearence() }
    }

    @IBInspectable public var disabledButtonTextColor: UIColor = UIConstants.BrandColor.onBackground50 {
        didSet { updateAppearence() }
    }

    @IBInspectable public var dotPulseViewColor: UIColor = UIConstants.BrandColor.backgroundSecondary {
        didSet { dotPulseActivityView.color = dotPulseViewColor }
    }

    @IBInspectable public var shadowColor: UIColor = UIConstants.BrandColor.primaryButtonShadow {
        didSet { layer.shadowColor = shadowColor.cgColor }
    }

    @IBInspectable public var shadowOffset: CGSize = CGSize(width: 0, height: 3) {
        didSet { layer.shadowOffset = shadowOffset }
    }

    @IBInspectable public var cornerRadius: CGFloat = UIConstants.Size.ButtonCornerRadius {
        didSet { updateAppearence() }
    }

    @IBInspectable public var shadowRadius: CGFloat = UIConstants.Size.ButtonShadowRadius

    public var title: String = "" {
        didSet {
            textableView.text = title
            innerButton.setTitle(title, for: .normal)
        }
    }

    public var defaultText: String? {
        didSet {
            title = defaultText ?? ""
        }
    }

    public var isEnabled: Bool {
        get { innerButton.isEnabled }
        set { innerButton.isEnabled = newValue }
    }

    public var action: (() -> Void)?

    private let defaultMargins = UIEdgeInsets(top: 18, left: 40, bottom: 18, right: 40)

    // MARK: - Lifecycle

    public override func initView() {
        super.initView()

        contentView?.layoutMargins = defaultMargins

        // Rounded corners
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false

        // Shadow
        if shadowOffset != .zero {
            layer.shadowRadius = shadowRadius
            layer.shadowOpacity = 0.6
            layer.masksToBounds = false
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = shadowOffset
        }

        // Title
        textableView.text = title
        textableView.setupAdjustedFontWith(font: UIConstants.Font.semiBold, multiplier: 2)
        textableView.isHidden = true

        innerButton.setTitle(title, for: .normal)
        innerButton.titleLabel?.textAlignment = .center
        innerButton.titleLabel?.setupAdjustedFontWith(font: UIConstants.Font.semiBold, multiplier: 2)
        innerButton.accessibilityIdentifier = AccessibilityIdentifier.TimeLine.serviceSelectionButton
        contentMode = .center

        // Background
        backgroundColor = .clear
        contentView?.backgroundColor = .clear

        // Dot Pulse Animation
        dotPulseActivityView.numberOfDots = UIConstants.Animation.DotPulseAnimationDotsNumber
        dotPulseActivityView.color = dotPulseViewColor
        dotPulseActivityView.padding = UIConstants.Size.ButtonDotPulseAnimationPadding

        updateAppearence()

        let maxButtonWidth = UIScreen.main.bounds.width - 2 * UIConstants.Size.PrimaryButtonMargin
        innerButton.widthAnchor.constraint(lessThanOrEqualToConstant: maxButtonWidth).isActive = true

        // Constraints for circle button
        buttonHeightConstraint = heightAnchor.constraint(equalToConstant: UIConstants.Size.ButtonAnimatingSize)
        buttonWidthConstraint = widthAnchor.constraint(equalToConstant: UIConstants.Size.ButtonAnimatingSize)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateAppearence()
    }

    /// Animating
    public func startAnimating(makeCircle: Bool = true) {
        if makeCircle {
            [buttonWidthConstraint, buttonHeightConstraint].forEach({ $0?.isActive = true })
            contentView?.layoutMargins = .zero
        }
//        innerButton.setTitle("", for: .normal)
//        textableView.text = ""
        innerButton.alpha = 0
        textableView.alpha = 0
        dotPulseActivityView.startAnimating()
    }

    public func stopAnimating() {
        dotPulseActivityView.stopAnimating()
//        innerButton.setTitle(title, for: .normal)
//        textableView.text = title
        innerButton.alpha = 0
        textableView.alpha = 0
        [buttonWidthConstraint, buttonHeightConstraint].forEach({ $0?.isActive = false })
        contentView?.layoutMargins = defaultMargins
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

    // MARK: - IBActions

    @IBAction func buttonPressed(_: Any) {
        // call button action
        action?()
    }

    private func updateAppearence() {
        backgroundColor = isEnabled ? enabledButtonBackgroundColor : disabledButtonBackgroundColor
        layer.cornerRadius = bounds.height / 2

        if shadowOffset != .zero {
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        }

        let titleColor = isEnabled ? enabledButtonTextColor : disabledButtonTextColor
        textableView.textColor = titleColor
        innerButton.setTitleColor(titleColor, for: .normal)
    }
}
