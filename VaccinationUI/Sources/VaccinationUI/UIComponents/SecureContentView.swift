//
//  SecureContentView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class SecureContentView: XibView {
    //  MARK: - Properties

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var textStackView: UIStackView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var bodyLabel: UILabel!
    @IBOutlet public var imageView: UIImageView!

    public var titleAttributedString: NSAttributedString? {
        didSet { updateView() }
    }

    public var bodyAttributedString: NSAttributedString? {
        didSet { updateView() }
    }

    //  MARK: - Lifecycle

    override public func initView() {
        super.initView()
        stackView.spacing = .space_16
        textStackView.spacing = .space_2
        imageView.tintColor = .brandAccent
    }

    //  MARK: - Methods

    private func setupAccessibility() {
        let accessibilityLabelText = "\(titleAttributedString?.string ?? "") \(bodyAttributedString?.string ?? "")"
        enableAccessibility(label: accessibilityLabelText, traits: .staticText)
    }

    internal func updateView() {
        titleLabel.attributedText = titleAttributedString
        bodyLabel.attributedText = bodyAttributedString

        setupAccessibility()
    }
}
