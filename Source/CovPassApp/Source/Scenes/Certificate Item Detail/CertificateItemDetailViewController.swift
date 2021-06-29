//
//  CertificateItemDetailViewController.swift
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

class CertificateItemDetailViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var itemStackView: UIStackView!
    @IBOutlet var titleLabel: PlainLabel!
    @IBOutlet var subtitleLabel: PlainLabel!
    @IBOutlet var qrCodeButton: MainButton!
    @IBOutlet var infoLabel1: LinkLabel!
    @IBOutlet var infoLabel2: LinkLabel!

    // MARK: - Properties

    private(set) var viewModel: CertificateItemDetailViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: CertificateItemDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // MARK: - Methods

    private func setupView() {
        view.backgroundColor = .backgroundPrimary
        scrollView.contentInset = .init(top: .space_24, left: .zero, bottom: .space_70, right: .zero)

        setupNavigationBar()
        setupHeadline()
        setupList()
        setupButton()
        setupInfo()
    }

    private func setupNavigationBar() {
        title = viewModel.title
        navigationController?.navigationBar.backIndicatorImage = .arrowBack
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = .arrowBack
        navigationController?.navigationBar.tintColor = .onBackground100

        let deleteIcon = UIBarButtonItem(image: .delete, style: .plain, target: self, action: #selector(deleteCertificate))
        deleteIcon.tintColor = .error
        navigationItem.rightBarButtonItem = deleteIcon
    }

    private func setupHeadline() {
        titleLabel.attributedText = viewModel.headline.styledAs(.header_1).colored(.onBackground100)
        titleLabel.layoutMargins = .init(top: .zero, left: .space_24, bottom: .space_24, right: .space_24)
        subtitleLabel.attributedText = "vaccination_certificate_detail_view_data_vaccine_recovery".localized.styledAs(.body).colored(.onBackground70)
        subtitleLabel.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        subtitleLabel.isHidden = !viewModel.showSubtitle
        stackView.setCustomSpacing(.space_24, after: subtitleLabel)
    }

    private func setupList() {
        viewModel.items.forEach { item in
            if !item.1.isEmpty {
                let view = ParagraphView()
                view.attributedTitleText = item.0.styledAs(.header_3)
                view.attributedBodyText = item.1.styledAs(.body)
                view.layoutMargins.top = .space_12
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
        infoLabel1.attributedText = "vaccination_certificate_detail_view_data_vaccine_note_de".localized.styledAs(.body)
        infoLabel1.layoutMargins = .init(top: .zero, left: .space_24, bottom: .space_24, right: .space_24)
        infoLabel2.attributedText = "vaccination_certificate_detail_view_data_vaccine_note_en".localized.styledAs(.body)
        infoLabel2.layoutMargins = .init(top: .zero, left: .space_24, bottom: .space_40, right: .space_24)
    }

    @objc private func deleteCertificate() {
        viewModel.deleteCertificate()
    }
}
