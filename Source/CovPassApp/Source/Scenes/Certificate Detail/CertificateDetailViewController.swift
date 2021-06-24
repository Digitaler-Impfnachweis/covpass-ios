//
//  CertificateDetailViewController.swift
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

class CertificateDetailViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var vaccinationsStackView: UIStackView!
    @IBOutlet var nameHeadline: PlainLabel!
    @IBOutlet var immunizationContainerView: UIView!
    @IBOutlet var immunizationView: ParagraphView!
    @IBOutlet var immunizationButtonContainerView: UIStackView!
    @IBOutlet var immunizationButton: MainButton!
    @IBOutlet var personalDataHeadline: PlainLabel!
    @IBOutlet var allCertificatesHeadline: PlainLabel!
    @IBOutlet var nameView: ParagraphView!
    @IBOutlet var birtdateView: ParagraphView!

    // MARK: - Properties

    private(set) var viewModel: CertificateDetailViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: CertificateDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupView()
        viewModel.refresh()
    }

    // MARK: - Methods

    private func setupView() {
        view.backgroundColor = .backgroundPrimary
        scrollView.contentInset = .init(top: .space_24, left: .zero, bottom: .space_70, right: .zero)

        setupHeadline()
        setupImmunizationView()
        setupPersonalData()
        setupCertificates()
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        title = ""
        navigationController?.navigationBar.backIndicatorImage = .arrowBack
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = .arrowBack
        navigationController?.navigationBar.tintColor = .onBackground100

        let favoriteIcon = UIBarButtonItem(image: viewModel.favoriteIcon, style: .plain, target: self, action: #selector(toggleFavorite))
        favoriteIcon.tintColor = .onBackground100
        navigationItem.rightBarButtonItem = favoriteIcon
    }

    private func setupHeadline() {
        nameHeadline.attributedText = viewModel.name.styledAs(.header_1).colored(.onBackground100)
        nameHeadline.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        stackView.setCustomSpacing(.space_24, after: nameHeadline)
    }

    private func setupImmunizationView() {
        immunizationContainerView.layoutMargins.top = .space_24
        immunizationContainerView.layoutMargins.bottom = .space_24
        immunizationContainerView.backgroundColor = .neutralWhite
        immunizationView.stackView.alignment = .top
        immunizationView.bottomBorder.isHidden = true
        immunizationView.image = viewModel.immunizationIcon
        immunizationView.attributedTitleText = viewModel.immunizationTitle.styledAs(.header_3)
        immunizationView.attributedBodyText = "recovery_certificate_overview_message".localized.styledAs(.body).colored(.onBackground70)
        immunizationView.layoutMargins.bottom = .space_24

        immunizationButton.title = "recovery_certificate_overview_action_button_title".localized

        immunizationButton.action = { [weak self] in
            self?.viewModel.immunizationButtonTapped()
        }
        stackView.setCustomSpacing(.space_24, after: immunizationButtonContainerView)
    }

    private func setupPersonalData() {
        stackView.setCustomSpacing(.space_12, after: personalDataHeadline)
        personalDataHeadline.attributedText = "certificates_overview_personal_data_title".localized.styledAs(.header_2)
        personalDataHeadline.layoutMargins = .init(top: .space_30, left: .space_24, bottom: .zero, right: .space_24)

        nameView.attributedTitleText = "certificates_overview_personal_data_name".localized.styledAs(.header_3)
        nameView.attributedBodyText = viewModel.name.styledAs(.body)
        nameView.contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)

        birtdateView.attributedTitleText = "certificates_overview_personal_data_date_of_birth".localized.styledAs(.header_3)
        birtdateView.attributedBodyText = viewModel.birthDate.styledAs(.body)
        birtdateView.contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)

        allCertificatesHeadline.attributedText = "certificates_overview_all_certificates_title".localized.styledAs(.header_2)
        allCertificatesHeadline.layoutMargins = .init(top: .space_30, left: .space_24, bottom: .space_16, right: .space_24)
    }

    private func setupCertificates() {
        vaccinationsStackView.subviews.forEach {
            $0.removeFromSuperview()
            self.vaccinationsStackView.removeArrangedSubview($0)
        }
        viewModel.items.forEach {
            self.vaccinationsStackView.addArrangedSubview($0)
        }
    }

    @objc private func toggleFavorite() {
        viewModel.toggleFavorite()
    }
}

extension CertificateDetailViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        setupView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {
        // already handled in ViewModel
    }
}