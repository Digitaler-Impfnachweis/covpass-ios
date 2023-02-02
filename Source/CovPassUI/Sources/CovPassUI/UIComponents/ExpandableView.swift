//
//  ExpandableView.swift
//
//
//  Created by Fatih Karakurt on 23.01.23.
//

import Foundation
import UIKit

public class ExpandableView: UIView {
    var stackView: UIStackView
    var headerStackView: UIStackView
    var contentStackView: UIStackView
    var titleLabel: PlainLabel
    var expandIndicatorIcon: UIImageView
    var bodyLabel: PlainLabel
    var footerLinkLabel: LinkLabel
    private var isExpanded: Bool {
        didSet {
            toggleView()
        }
    }

    private var iconExpanded: UIImage
    private var iconCollapsed: UIImage

    public var stackViewMarings: UIEdgeInsets {
        didSet {
            stackView.layoutMargins = stackViewMarings
        }
    }

    override init(frame _: CGRect) {
        stackView = .init(frame: .zero)
        contentStackView = .init(frame: .zero)
        headerStackView = .init(frame: .zero)
        titleLabel = .init(frame: .zero)
        expandIndicatorIcon = .init(frame: .zero)
        bodyLabel = .init(frame: .zero)
        footerLinkLabel = .init(frame: .zero)
        isExpanded = true
        iconExpanded = .iconBlueUpArrow
        iconCollapsed = .iconBlueDownArrow
        expandIndicatorIcon.image = iconExpanded
        expandIndicatorIcon.setConstant(width: 14)
        expandIndicatorIcon.contentMode = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        headerStackView.isLayoutMarginsRelativeArrangement = true
        headerStackView.layoutMargins = .init(top: 18, left: 0, bottom: 24, right: 4)
        stackViewMarings = .init()
        super.init(frame: .zero)
        configureView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureView() {
        configureHeaderStackView()
        configureContentStackView()
        configureStackView()
        addGestureRecognizerHeaderStackView()
    }

    func configureHeaderStackView() {
        headerStackView.alignment = .fill
        headerStackView.distribution = .fill
        headerStackView.axis = .horizontal
        headerStackView.spacing = .space_8
        headerStackView.addArrangedSubview(titleLabel)
        let spacer = UIView()
        headerStackView.addArrangedSubview(spacer)
        headerStackView.addArrangedSubview(expandIndicatorIcon)
    }

    func configureContentStackView() {
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = .space_10
        contentStackView.addArrangedSubview(bodyLabel)
        contentStackView.addArrangedSubview(footerLinkLabel)
        let spacer = UIView()
        spacer.setConstant(height: 20)
        contentStackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(contentStackView)
    }

    func configureStackView() {
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.addArrangedSubview(headerStackView)
        stackView.addArrangedSubview(contentStackView)
        addSubview(stackView)
        stackView.pinEdges(to: self)
    }

    func addGestureRecognizerHeaderStackView() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        headerStackView.addGestureRecognizer(gestureRecognizer)
    }

    @objc func headerTapped() {
        isExpanded = !isExpanded
    }

    private func toggleView() {
        contentStackView.isHidden = !isExpanded
        expandIndicatorIcon.image = isExpanded ? iconExpanded : iconCollapsed
    }

    public func updateView(title: NSAttributedString?, body: NSAttributedString?, footer: NSAttributedString?) {
        titleLabel.attributedText = title
        bodyLabel.attributedText = body
        footerLinkLabel.attributedText = footer
        isExpanded = false
    }
}
