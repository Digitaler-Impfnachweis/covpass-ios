//
//  ImprintViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import WebKit

public class ImprintViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var stackview: UIStackView!
    @IBOutlet var titelLabel: LinkLabel!
    @IBOutlet var subtitleLabel: LinkLabel!
    @IBOutlet var publisherLabel: LinkLabel!
    @IBOutlet var address: LinkLabel!
    @IBOutlet var contactTitleLabel: LinkLabel!
    @IBOutlet var contactMailLabel: LinkLabel!
    @IBOutlet var contactFormLabel: LinkLabel!
    @IBOutlet var vatNumberTitleLabel: LinkLabel!
    @IBOutlet var vatNumberLabel: LinkLabel!

    // MARK: - Properties

    private var viewModel: ImprintViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ImprintViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .uiBundle)
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureTextsAndStyles()
    }

    // MARK: - Private

    private func configureTextsAndStyles() {
        stackview.isLayoutMarginsRelativeArrangement = true
        stackview.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .space_18, right: .space_24)
        titelLabel.textableView.textContainerInset = .init(top: .zero, left: .zero, bottom: .zero, right: .zero)
        subtitleLabel.textableView.textContainerInset = .init(top: .zero, left: .zero, bottom: .zero, right: .zero)
        publisherLabel.textableView.textContainerInset = .init(top: .zero, left: .zero, bottom: .zero, right: .zero)
        address.textableView.textContainerInset = .init(top: .zero, left: .zero, bottom: .zero, right: .zero)
        contactTitleLabel.textableView.textContainerInset = .init(top: .zero, left: .zero, bottom: .zero, right: .zero)
        contactMailLabel.textableView.textContainerInset = .init(top: .zero, left: .zero, bottom: .zero, right: .zero)
        contactFormLabel.textableView.textContainerInset = .init(top: .zero, left: .zero, bottom: .zero, right: .zero)
        vatNumberTitleLabel.textableView.textContainerInset = .init(top: .zero, left: .zero, bottom: .zero, right: .zero)
        vatNumberLabel.textableView.textContainerInset = .init(top: .zero, left: .zero, bottom: .zero, right: .zero)

        titelLabel.attributedText = viewModel.title.styledAs(.header_1)
        subtitleLabel.attributedText = viewModel.subtitle.styledAs(.body)
        publisherLabel.attributedText = viewModel.publisher.styledAs(.header_3)
        address.attributedText = viewModel.address.styledAs(.body)
        contactTitleLabel.attributedText = viewModel.contactTitle.styledAs(.header_3)
        contactMailLabel.attributedText = viewModel.contactMail.styledAs(.header_3).colored(.brandAccent)
        contactFormLabel.linkFont = .scaledBoldBody
        contactFormLabel.attributedText = viewModel.contactForm.styledAs(.body)
        vatNumberTitleLabel.attributedText = viewModel.vatNumberTitle.styledAs(.header_3)
        vatNumberLabel.attributedText = viewModel.vatNumber.styledAs(.body)
    }
}
