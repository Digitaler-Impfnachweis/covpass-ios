//
//  OnboardingLogoAndTextView.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

class OnboardingLogoAndTextView: MarginableXibView {
    @IBOutlet var logoContentView: UIView!
    @IBOutlet var textLabel: UILabel!

    @IBInspectable var textKey: String? {
        didSet {
            textLabel.text = textKey
        }
    }

    @IBInspectable var logoName: String? {
        didSet {
            setupLogo()
        }
    }

    public override var margins: [Margin] {
        return [
            RelatedViewMargin(constant: 23, relatedViewType: OnboardingLogoAndTextView.self),
//            RelatedViewMargin(constant: 52, relatedViewType: FixedSpacer.self)
        ]
    }

    override func initView() {
        super.initView()

        setupView()
        configureBoldText()
    }

    private func setupView() {
        try? UIFont.loadCustomFonts()
        contentView?.backgroundColor = UIConstants.BrandColor.brandBase
        textLabel.font = UIFont.ibmPlexSansRegular(with: 14)
        textLabel.textColor = UIConstants.BrandColor.onBrandBase
        logoContentView.layer.cornerRadius = logoContentView.frame.size.width / 2
        logoContentView.clipsToBounds = true
    }

    private func configureBoldText() {
        guard let text = textKey, let boldParts = text.boldParts, !boldParts.isEmpty else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.configureBoldParts()
        textLabel.attributedText = attributedString
    }

    private func setupLogo() {
//        guard let logo = logoName else { return }

//        let lottieLogoView = AnimationView(animationName: logo, customBundle: PlatformUIFactory.shared.animationOverrideBundle)
//        let primaryKeypath = AnimationKeypath(keypath: UIConstants.LottieKeypathName.Primary01Color)
//        let actionKeypath = AnimationKeypath(keypath: UIConstants.LottieKeypathName.Action01Color)
//
//        let actionColorValue = ColorValueProvider(HUIConstants.BrandColor.brandAccent.lottieColorValue)
//        let primaryColorValue = ColorValueProvider(HUIConstants.BrandColor.brandBase.lottieColorValue)
//
//        lottieLogoView.setValueProvider(actionColorValue, keypath: actionKeypath)
//        lottieLogoView.setValueProvider(primaryColorValue, keypath: primaryKeypath)
//
//        lottieLogoView.contentMode = .scaleAspectFit
//        logoContentView.addSubview(lottieLogoView)
//        lottieLogoView.pinToEdges(of: logoContentView)
    }
}
