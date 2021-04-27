//
//  Headline.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

@IBDesignable
public class Headline: XibView, Textable {
    @IBOutlet public var textableView: UILabel!

    @IBInspectable public var isCentered: Bool = false {
        didSet {
            textableView.textAlignment = isCentered ? .center : .left
        }
    }

    @IBInspectable public var textColor: UIColor? {
        didSet {
            textableView.textColor = textColor
        }
    }

    public var font: UIFont? {
        didSet {
            textableView.font = font
            textableView.adjustsFontForContentSizeCategory()
        }
    }

    public var isTransparent: Bool = false {
        didSet {
            let color = isTransparent ? .clear : UIConstants.BrandColor.backgroundPrimary
            backgroundColor = color
            contentView?.backgroundColor = color
        }
    }

    @IBInspectable public var needsTextAlignmentCenter: Bool = false

    public override var margins: [Margin] {
        return [
            RelatedViewMargin(constant: 24, relatedViewType: Headline.self),
            RelatedViewMargin(constant: 12, relatedViewType: ParagraphView.self),
            RelatedViewMargin(constant: 40, relatedViewType: ParagraphView.self, type: .top),
            RelatedViewMargin(constant: 40, relatedViewType: Spacer.self, type: .top)
        ]
    }

    // MARK: - Lifecycle

    public override func initView() {
        super.initView()
        layoutMargins = .init(top: 12, left: 24, bottom: 16, right: 24)

        if needsTextAlignmentCenter {
            textableView.textAlignment = .center
        }

        isTransparent = false
        font = UIFont.ibmPlexSansSemiBold(with: 20)
        textColor = UIConstants.BrandColor.onBackground100
    }
}
