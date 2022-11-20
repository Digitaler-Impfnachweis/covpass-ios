//
//  ImmunityScanCardView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

public class ImmunityScanCardView: XibView {
    
    // MARK: - Outlets

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var titleLabel: PlainLabel!
    @IBOutlet private var infoView: UIView!
    @IBOutlet private var descriptionLabel: PlainLabel!
    @IBOutlet private var infoLabel: PlainLabel!
    @IBOutlet private var actionButton: MainButton!
    
    // MARK: - Public properties

    public var action: (()->Void)? {
        didSet {
            actionButton.action = action
        }
    }
    
    
    // MARK: - Properties
    private let cornerRadius: CGFloat = 14
    private let shadowRadius: CGFloat = 16
    private let shadowOpacity: CGFloat = 0.2
    private let shadowOffset: CGSize = .init(width: 0, height: -4)

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        contentView?.backgroundColor = .brandBase
        contentView?.layer.cornerRadius = cornerRadius
        contentView?.layer.shadowColor = UIColor.neutralBlack.cgColor
        contentView?.layer.shadowRadius = shadowRadius
        contentView?.layer.shadowOpacity = Float(shadowOpacity)
        contentView?.layer.shadowOffset = shadowOffset
        actionButton.style = .secondary
        actionButton.icon = .scan
    }
    
    public func set(title: NSAttributedString,
                    titleAccessibility: String,
                    titleEdges: UIEdgeInsets,
                    description: NSAttributedString,
                    descriptionEdges: UIEdgeInsets,
                    infoText: NSAttributedString?,
                    infoTextEdges: UIEdgeInsets,
                    actionTitle: String) {
        titleLabel.attributedText = title
        titleLabel.contentView?.layoutMargins = titleEdges
        titleLabel.enableAccessibility(value: titleAccessibility)
        descriptionLabel.attributedText = description
        descriptionLabel.contentView?.layoutMargins = descriptionEdges
        infoLabel.attributedText = infoText
        infoLabel.contentView?.layoutMargins = infoTextEdges
        actionButton.title = actionTitle
        infoView.isHidden = infoText.isNilOrEmpty
    }
}
