//
//  LinkTextView.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

/// A custom `UITextView` processing bold or link text
public class LinkTextView: UITextView {
    ///
    /// !!! Find all occurences in code with regular expression (?<=#).+::.+(?=#) !!!
    /// !!! If you change delimiter and/or separator adapt regex accordingly !!!
    ///
    struct Constants {
        static let delimiter = "#"
        static let separator = "::"
    }

    struct TextComponents {
        var regularText: String
        var linkKeyValue: [String: String]
    }

    public var linkText: String? {
        didSet {
            let linkParts = linkActionParts(for: linkText ?? "")
            configure(with: linkParts.regularText, links: linkParts.linkKeyValue)
        }
    }

    public var linkTextFont: UIFont = UIConstants.Font.regular {
        didSet {
            font = UIFontMetrics.default.scaledFont(for: linkTextFont)
        }
    }

    @IBInspectable public var isCentered: Bool = false
    /// Set this before you set the `linkTextKey` or in the storyboard directly.
    @IBInspectable public var linkIsSemiBold: Bool = true

    public var linkColor = UIConstants.BrandColor.brandAccent70 {
        didSet {
            linkTextAttributes = [NSAttributedString.Key.foregroundColor: linkColor]
        }
    }

    var style: Style = Style.light

    enum Style {
        case light, lightSmall, medium, mediumSmall
        init(small: Bool, light: Bool) {
            switch (small, light) {
            case (false, false):
                self = .medium
            case (false, true):
                self = .light
            case (true, false):
                self = .mediumSmall
            case (true, true):
                self = .lightSmall
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    func setup() {
        isEditable = false
        isSelectable = true
        isUserInteractionEnabled = true
        textDragInteraction?.isEnabled = false
        backgroundColor = .clear

        textColor = UIConstants.BrandColor.onBackground100
        linkTextAttributes = [NSAttributedString.Key.foregroundColor: linkColor]

        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        isScrollEnabled = false
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutManager.usesFontLeading = false
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard super.point(inside: point, with: event),
            let pos = closestPosition(to: point),
            let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: UITextDirection.layout(UITextLayoutDirection.left))
        else { return false }
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }

    public override var selectedTextRange: UITextRange? {
        // Avoid selecting text with double click
        get {
            return nil
        }
        set {}
    }

    func linkActionParts(for localizedString: String) -> TextComponents {
        var components = localizedString.components(separatedBy: Constants.delimiter)
        if components.count > 3 {
            // if there are delimiter character in the url itself, join the components back
            let joinedComponents = components[1 ... components.count - 2].joined(separator: Constants.delimiter)
            components = [components[0], joinedComponents, components[components.count - 1]]
        }
        // get all #key::value# pairs
        var keysAndValues = [String: String]()
        let text = components.map { part -> String in
            let subComponents = part.components(separatedBy: Constants.separator)
            if subComponents.count == 2 {
                let key = subComponents[0]
                let typeId = subComponents[1]
                keysAndValues[key] = typeId
                return key
            }
            return part
        }
        let string = text.reduce("", +)
        return TextComponents(regularText: string, linkKeyValue: keysAndValues)
    }

    private func configure(with string: String, links: [String: String]) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = isCentered ? .center : .left
        paragraphStyle.lineSpacing = UIConstants.Size.TextLineSpacing

        let font = UIFontMetrics.default.scaledFont(for: linkTextFont)
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: textColor as AnyObject,
                                                         .backgroundColor: UIColor.clear as AnyObject,
                                                         .paragraphStyle: paragraphStyle]

        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        attributedString.configureLinkParts(linkParts: links, linkIsSemiBold: linkIsSemiBold)
        attributedString.configureBoldParts(UIFont.ibmPlexSansSemiBold(with: linkTextFont.pointSize) ?? UIFont())

        attributedText = attributedString
        adjustsFontForContentSizeCategory = true
    }
}

extension LinkTextView: UITextFieldDelegate {
    func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
