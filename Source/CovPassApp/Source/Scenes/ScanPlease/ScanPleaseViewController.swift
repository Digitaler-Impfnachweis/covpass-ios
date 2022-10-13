//
//  ScanPleaseViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit
import WebKit

private enum Constants {
    enum Layout {
        static let actionLineHeight: CGFloat = 17
    }
}

class ScanPleaseViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var toolbarView: CustomToolbarView!
    @IBOutlet var headerImageView: UIImageView!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var textView: ParagraphView!
    @IBOutlet weak var linkDescriptionView: ParagraphView!
    @IBOutlet weak var actionView: ListItemView!

    @IBOutlet weak var contentStackView: UIStackView!
    // MARK: - Properties

    private(set) var viewModel: ScanPleaseViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ScanPleaseViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.accessibilityOpeningAnnounce)
        UIAccessibility.post(notification: .layoutChanged, argument: headline.textLabel)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeadline()
        configureToolbarView()
        configureContentView()
        configureAccessiblity()
    }

    // MARK: - Private

    private func configureContentView() {
        headerImageView.image = UIImage.scanPleaseIllustration

        textView.updateView(body: viewModel.text.styledAs(.body))
        textView.bottomBorder.isHidden = true

        linkDescriptionView.updateView(body: viewModel.linkDescription.styledAs(.body))
        linkDescriptionView.bottomBorder.isHidden = true

        actionView.textLabel.attributedText = viewModel.linkText.styledAs(.header_3).lineHeight(Constants.Layout.actionLineHeight)
        actionView.action = { [weak self] in
            self?.viewModel.openCheckPassLink()
        }
        actionView.tintColor = .brandAccent

        contentStackView.setCustomSpacing(.space_40, after: headerImageView)
        contentStackView.setCustomSpacing(.space_40, after: textView)
    }

    private func configureHeadline() {
        headline.attributedTitleText = viewModel.title.styledAs(.header_2)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.layoutMargins.bottom = .space_24
    }

    private func configureToolbarView() {
        toolbarView.state = .confirm(viewModel.buttonOkText)
        toolbarView.layoutMargins.top = .space_24
        toolbarView.delegate = self
    }

    private func configureAccessiblity() {
        headline.actionButton.enableAccessibility(label: viewModel.accessibilityClose)
        headerImageView.enableAccessibility(label: viewModel.accessibilityImage)
    }

}

// MARK: - CustomToolbarViewDelegate

extension ScanPleaseViewController: CustomToolbarViewDelegate {
    func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .textButton:
            viewModel.done()
        default:
            return
        }
    }
}

// MARK: - ModalInteractiveDismissibleProtocol

extension ScanPleaseViewController: ModalInteractiveDismissibleProtocol {
    func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
