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
    @IBOutlet var buttonStackView: UIStackView!
    @IBOutlet var titleLabel: PlainLabel!
    @IBOutlet var subtitleLabel: PlainLabel!
    @IBOutlet var hintView: HintView!
    @IBOutlet var qrCodeButton: MainButton!
    @IBOutlet var pdfExportButton: MainButton!
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
        setupHintView()
        setupList()
        setupButtons()
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
        navigationItem.rightBarButtonItem?.accessibilityLabel = String("accessibility_certificate_detail_view_label_delete_button".localized)
    }

    private func setupHeadline() {
        titleLabel.attributedText = viewModel.headline.styledAs(.header_1).colored(.onBackground100)
        titleLabel.layoutMargins = .init(top: .zero, left: .space_24, bottom: .space_24, right: .space_24)
        subtitleLabel.attributedText = "vaccination_certificate_detail_view_vaccination_note".localized.styledAs(.body).colored(.onBackground70)
        subtitleLabel.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        subtitleLabel.isHidden = !viewModel.showSubtitle
        stackView.setCustomSpacing(.space_24, after: subtitleLabel)
    }

    private func setupHintView() {
        hintView.isHidden = true
        hintView.iconView.image = .warning
        hintView.containerView.backgroundColor = .infoBackground
        hintView.containerView?.layer.borderColor = UIColor.infoAccent.cgColor
        stackView.setCustomSpacing(.space_24, after: hintView)
        if viewModel.isExpired {
            hintView.isHidden = false
            hintView.titleLabel.attributedText = "certificate_expired_detail_view_note_title".localized.styledAs(.header_3)
            hintView.bodyLabel.attributedText = "certificate_expired_detail_view_note_message".localized.styledAs(.body)
        } else if let date = viewModel.expiresSoonDate {
            hintView.isHidden = false
            hintView.iconView.image = .activity
            hintView.titleLabel.attributedText = String(format: "certificate_expires_detail_view_note_title".localized, DateUtils.displayDateFormatter.string(from: date), DateUtils.displayTimeFormatter.string(from: date)).styledAs(.header_3)
            hintView.bodyLabel.attributedText = "certificate_expires_detail_view_note_message".localized.styledAs(.body)
            hintView.containerView.backgroundColor = .onBackground50
            hintView.containerView.layer.borderColor = UIColor.onBrandBase.cgColor
        } else if viewModel.isInvalid {
            hintView.isHidden = false
            hintView.titleLabel.attributedText = "certificate_invalid_detail_view_note_title".localized.styledAs(.header_3)
            hintView.bodyLabel.attributedText = "certificate_invalid_detail_view_note_message".localized.styledAs(.body)
        }
    }

    private func setupList() {
        viewModel.items.forEach { item in
            if !item.value.isEmpty {
                let view = ParagraphView()
                view.attributedTitleText = item.label.styledAs(.header_3)
                view.attributedBodyText = item.value.styledAs(.body)
                view.accessibilityLabel = item.accessibilityLabel
                view.accessibilityIdentifier = item.accessibilityIdentifier
                view.layoutMargins.top = .space_12
                itemStackView.addArrangedSubview(view)
            }
        }
    }

    private func setupButtons() {
        buttonStackView.spacing = .space_24

        qrCodeButton.title = "vaccination_certificate_detail_view_qrcode_action_button_title".localized
        qrCodeButton.style = .primary
        qrCodeButton.icon = .scan
        qrCodeButton.tintColor = .white
        qrCodeButton.action = viewModel.showQRCode

        pdfExportButton.title = "vaccination_certificate_detail_view_pdf_action_button_title".localized
        pdfExportButton.style = .secondary
        pdfExportButton.icon = .share
        pdfExportButton.action = viewModel.startPDFExport

        pdfExportButton.disable()
        if viewModel.canExportToPDF {
            // Some certificates such as tests or non-German ones cannot be exported
            pdfExportButton.enable()
        } else {
            let disclaimer = SecureContentView()
            disclaimer.imageView.image = .info
            disclaimer.bodyAttributedString = "vaccination_certificate_detail_view_pdf_action_button_note".localized.styledAs(.body)
            buttonStackView.addArrangedSubview(disclaimer)
        }
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
