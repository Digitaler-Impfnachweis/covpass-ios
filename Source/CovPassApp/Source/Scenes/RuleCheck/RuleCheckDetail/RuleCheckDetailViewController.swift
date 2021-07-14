//
//  RuleCheckDetailViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import Scanner
import UIKit

class RuleCheckDetailViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var headerView: InfoHeaderView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var itemStackView: UIStackView!
    @IBOutlet var subtitleLabel: PlainLabel!
    @IBOutlet var qrCodeButton: MainButton!
    @IBOutlet var infoLabel1: LinkLabel!
    @IBOutlet var infoLabel2: LinkLabel!
    @IBOutlet var resultView: HintView!

    // MARK: - Properties

    private(set) var viewModel: RuleCheckDetailViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: RuleCheckDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundPrimary
        scrollView.contentInset = .init(top: .zero, left: .zero, bottom: .space_70, right: .zero)

        setupHeadline()
        setupList()
        setupButton()
        setupInfo()
        setupResultView()
    }

    // MARK: - Methods

    private func setupHeadline() {
        headerView.attributedTitleText = viewModel.title.styledAs(.header_2)
        headerView.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headerView.image = .close

        subtitleLabel.attributedText = viewModel.subtitle.styledAs(.body).colored(.onBackground70)
        subtitleLabel.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func setupList() {
        viewModel.items.forEach { item in
            if !item.1.isEmpty {
                let view = ParagraphResultView()
                view.attributedTitleText = item.0.styledAs(.header_3)
                view.attributedBodyText = item.1.styledAs(.body)
                view.resultFail = item.2
                view.resultOpen = item.3
                view.image = !item.3.isEmpty ? .warning : nil
                if !item.2.isEmpty {
                    view.image = .error
                }
                itemStackView.addArrangedSubview(view)
            }
        }
    }

    private func setupButton() {
        qrCodeButton.title = "vaccination_certificate_detail_view_qrcode_action_button_title".localized
        qrCodeButton.style = .secondary
        qrCodeButton.icon = .scan
        qrCodeButton.action = viewModel.showQRCode
    }

    private func setupInfo() {
        infoLabel1.attributedText = viewModel.infoText1.styledAs(.body)
        infoLabel1.layoutMargins = .init(top: .zero, left: .space_24, bottom: .space_24, right: .space_24)
        infoLabel2.attributedText = viewModel.infoText2.styledAs(.body)
        infoLabel2.layoutMargins = .init(top: .zero, left: .space_24, bottom: .space_40, right: .space_24)
    }

    private func setupResultView() {
        resultView.layoutMargins.bottom = .space_24
        resultView.iconView.image = viewModel.resultIcon
        resultView.titleLabel.attributedText = viewModel.resultTitle.styledAs(.header_3)
        resultView.bodyLabel.attributedText = viewModel.resultSubtitle.styledAs(.body)
        resultView.containerView?.backgroundColor = viewModel.resultColorBackground
        resultView.containerView?.layer.borderColor = viewModel.resultColor.cgColor
    }
}
