//
//  SecureContentView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

@IBDesignable
public class SecureContentView: MarginableXibView {
    
    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var title: UILabel!
    @IBOutlet public var body: LinkTextView!
    @IBOutlet public var imageView: UIImageView!

    internal static let BodyLeftInset: CGFloat = -5

    public var topMargin: CGFloat = 25
    public var marginToSecondaryButton: CGFloat = 40

    public var titleText: String? {
        didSet {
            if let text = titleText {
                title.text = text
                hasTitle = !text.isEmpty
                checkVisibility()
                setupAccessibility()
            }
        }
    }

    public var spacing: CGFloat? {
        didSet {
            guard let spacing = spacing else { return }
            stackView.spacing = spacing
        }
    }

    public var bodyText: String? {
        didSet {
            body.linkText = bodyText
            checkVisibility()
            setupAccessibility()
        }
    }

    public var bodyFont: UIFont? {
        didSet {
            guard let bodyFont = bodyFont else { return }
            let newFont = UIFont(descriptor: bodyFont.fontDescriptor, size: bodyFont.fontDescriptor.pointSize)
            body.adjustsFontForContentSizeCategory = true
            body.linkTextFont = newFont
        }
    }

    @IBInspectable internal var hasTitle: Bool = false {
        didSet {
            if !hasTitle {
                title.removeFromSuperview()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    public override func initView() {
        super.initView()
        setupView()
    }

    private func checkVisibility() {
        isHidden = (bodyText?.isEmpty ?? true) && !hasTitle
    }

    private func setupAccessibility() {
        let accessibilityLabelText = "\(titleText ?? "") \(bodyText ?? "")"
        enableAccessibility(label: accessibilityLabelText, traits: .staticText)
    }

    internal func setupView() {
        title.font = UIConstants.Font.semiBold
        title.adjustsFontForContentSizeCategory()
        title.textColor = UIConstants.BrandColor.onBackground100
        bodyFont = UIConstants.Font.regular
        body.textColor = UIConstants.BrandColor.onBackground100
        imageView.tintColor = UIConstants.BrandColor.brandAccent
    }
}
