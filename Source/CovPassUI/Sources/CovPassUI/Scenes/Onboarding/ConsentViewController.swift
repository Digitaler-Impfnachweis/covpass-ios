//
//  ConsentViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import WebKit

class ConsentViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var headline: PlainLabel!
    @IBOutlet var listItems: PlainLabel!
    @IBOutlet var descriptionText: PlainLabel!
    @IBOutlet var dataPrivacyInfoView: ListItemView!

    // MARK: - Properties

    private(set) var viewModel: ConsentPageViewModel

    public var infoViewAction: (() -> Void)?

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: ConsentPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureScrollView()
        configureImageView()
        configureHeadline()
        configureListItems()
        configureParagraphView()
        configureInfoView()
    }

    // MARK: - Methods

    private func configureScrollView() {
        scrollView.contentInset.top = .space_70
        scrollView.contentInset.bottom = .space_120
        scrollView.delegate = self
        if scrollView.isScrolledToBottom {
            viewModel.isScrolledToBottom = true
        }
    }

    private func configureImageView() {
        imageView.image = viewModel.image
        imageView.pinHeightToScaleAspectFit()
    }

    private func configureHeadline() {
        headline.attributedText = viewModel.title?.styledAs(.header_2)
        headline.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureListItems() {
        listItems.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .zero, right: .space_24)
        listItems.attributedText = viewModel.listItems
    }

    private func configureParagraphView() {
        descriptionText.attributedText = viewModel.info?.styledAs(.body).colored(.onBackground70)
        descriptionText.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureInfoView() {
        dataPrivacyInfoView.textLabel.attributedText = viewModel.dataPrivacyTitle
        dataPrivacyInfoView.action = infoViewAction
        dataPrivacyInfoView.showSeperator = true
        dataPrivacyInfoView.layoutMargins = .init(top: .space_40, left: .zero, bottom: .zero, right: .zero)
    }
}

extension ConsentViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.isScrolledToBottom = scrollView.isScrolledToBottom
    }
}
