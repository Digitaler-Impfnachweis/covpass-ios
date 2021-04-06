//
//  PrimaryButtonContainer.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

@IBDesignable
/// A custom button with support for rounded corners, shadow and animation
public class PrimaryButtonContainer: MarginableXibView, Textable {
    @IBOutlet var dotPulseActivityView: DotPulseActivityIndicator!

    @IBOutlet public var textableView: UILabel!
    @IBOutlet public var innerButton: UIButton!

    @IBOutlet public var leadingTitleInsetConstraint: NSLayoutConstraint!
    @IBOutlet public var trailingTitleInsetConstraint: NSLayoutConstraint!
    @IBOutlet public var topTitleInsetConstraint: NSLayoutConstraint!
    @IBOutlet public var bottomTitleInsetConstraint: NSLayoutConstraint!
    @IBOutlet public var minPreferredHeightConstraint: NSLayoutConstraint!

    var buttonWidthConstraint: NSLayoutConstraint?
    var buttonHeightConstraint: NSLayoutConstraint?
    private let animationDuration: TimeInterval = 0.2
    private var observerToken: NSKeyValueObservation?

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
        didSet {
            observerToken?.invalidate()
            innerButton.layer.cornerRadius = cornerRadius
        }
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

    // MARK: - Lifecycle

    public override func initView() {
        super.initView()

        try? UIFont.loadCustomFonts()

        // Rounded corners
        innerButton.layer.cornerRadius = cornerRadius
        innerButton.layer.masksToBounds = false

        // Shadow
        if shadowOffset != .zero {
            layer.shadowRadius = shadowRadius
            layer.shadowOpacity = 0.6
            layer.masksToBounds = false
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = shadowOffset
        }
        observerToken = observe(\.bounds) { [weak self] _, _ in
            guard let strongSelf = self else { return }
            strongSelf.innerButton.layer.cornerRadius = strongSelf.bounds.height / 2
            if strongSelf.shadowOffset != .zero {
                strongSelf.innerButton.layer.shadowPath = UIBezierPath(roundedRect: strongSelf.innerButton.bounds, cornerRadius: strongSelf.innerButton.layer.cornerRadius).cgPath
            }
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

        // Constraints
        if let titleLabel = innerButton.titleLabel {
            textableView.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
            textableView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
            textableView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
            textableView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        }
        let maxButtonWidth = UIScreen.main.bounds.width - 2 * UIConstants.Size.PrimaryButtonMargin
        innerButton.widthAnchor.constraint(lessThanOrEqualToConstant: maxButtonWidth).isActive = true

        // Constraints for circle button
        buttonHeightConstraint = innerButton.heightAnchor.constraint(equalToConstant: UIConstants.Size.ButtonAnimatingSize)
        buttonWidthConstraint = innerButton.widthAnchor.constraint(equalToConstant: UIConstants.Size.ButtonAnimatingSize)
    }

    deinit {
        observerToken?.invalidate()
    }

    /// Animating
    public func startAnimating(makeCircle: Bool = true) {
        if makeCircle {
            [buttonWidthConstraint, buttonHeightConstraint].forEach({ $0?.isActive = true })
            [leadingTitleInsetConstraint, trailingTitleInsetConstraint].forEach({ $0?.isActive = false })
        }
        innerButton.setTitle("", for: .normal)
        textableView.text = ""
        dotPulseActivityView.startAnimating()
    }

    public func stopAnimating() {
        dotPulseActivityView.stopAnimating()
        innerButton.setTitle(title, for: .normal)
        textableView.text = title
        [buttonWidthConstraint, buttonHeightConstraint].forEach({ $0?.isActive = false })
        [leadingTitleInsetConstraint, trailingTitleInsetConstraint].forEach({ $0?.isActive = true })
    }

    /// Enables the button and changes the background color to enabled color.
    public func enable() {
        isEnabled = true
        UIView.animate(withDuration: animationDuration) {
            self.updateAppearence()
        }
    }

    /// Disables the button and changes the background color to disabled color.
    public func disable() {
        isEnabled = false
        UIView.animate(withDuration: animationDuration) {
            self.updateAppearence()
        }
    }

    // MARK: - IBActions

    @IBAction func buttonPressed(_: Any) {
        // call button action
        action?()
    }

    private func updateAppearence() {
        innerButton.backgroundColor = isEnabled ? enabledButtonBackgroundColor : disabledButtonBackgroundColor
        let titleColor = isEnabled ? enabledButtonTextColor : disabledButtonTextColor
        textableView.textColor = titleColor
        innerButton.setTitleColor(titleColor, for: .normal)
    }
}
