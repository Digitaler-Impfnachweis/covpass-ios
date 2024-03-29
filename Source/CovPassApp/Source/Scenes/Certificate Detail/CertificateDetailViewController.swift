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

private enum Constants {
    enum Text {
        static let scanHintTitle = "certificates_overview_all_certificates_app_reference_title".localized
        static let scanHintText = "certificates_overview_all_certificates_app_reference_text".localized
    }
}

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
    @IBOutlet var reissueStackView: UIStackView!
    @IBOutlet var boosterHintView: HintView!
    @IBOutlet var personalDataHeadline: PlainLabel!
    @IBOutlet var allCertificatesHeadline: PlainLabel!
    @IBOutlet var nameView: ParagraphView!
    @IBOutlet var nameTransliteratedView: ParagraphView!
    @IBOutlet var birtdateView: ParagraphView!
    @IBOutlet var scanHintView: HintView!
    @IBOutlet var immunizationStatusView: ParagraphView!

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
        viewModel.updateBoosterCandiate()
        viewModel.updateReissueCandidate(to: true)
    }

    // MARK: - Methods

    private func setupView() {
        view.backgroundColor = .backgroundPrimary
        scrollView.contentInset = .init(top: .space_24, left: .zero, bottom: .space_70, right: .zero)
        setupHeadline()
        setupImmunizationView()
        setupBoosterHintView()
        setupReissueStackView()
        setupPersonalData()
        setupScanHintView()
        setupCertificates()
        setupNavigationBar()
        setupStatusView()
    }

    private func setupStatusView() {
        immunizationStatusView.setup(with: viewModel.immunizationStatusViewModel)
        immunizationStatusView.imageViewWidthConstraint.constant = 32
        immunizationStatusView.bottomBorder.isHidden = true
        immunizationStatusView.bottomBorder.layoutMargins.bottom = .space_24
        immunizationStatusView.isHidden = viewModel.immunizationStatusViewIsHidden
    }

    private func setupNavigationBar() {
        title = ""
        let backButton = UIBarButtonItem(image: .arrowBack,
                                         style: .done,
                                         target: self,
                                         action: #selector(backButtonTapped))
        backButton.accessibilityLabel = viewModel.accessibilityBackToStart
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .onBackground100
        if viewModel.favoriteIcon != nil {
            let favoriteIcon = UIBarButtonItem(image: viewModel.favoriteIcon, style: .plain, target: self, action: #selector(toggleFavorite))
            favoriteIcon.tintColor = .onBackground100
            navigationItem.rightBarButtonItem = favoriteIcon
        }
    }

    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupHeadline() {
        nameHeadline.attributedText = viewModel.name.styledAs(.header_1).colored(.onBackground100)
        nameHeadline.textableView.accessibilityTraits = .header
        nameHeadline.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        nameHeadline.textableView.accessibilityTraits = .header
        stackView.setCustomSpacing(.space_6, after: nameHeadline)
    }

    private func setupScanHintView() {
        scanHintView.isHidden = !viewModel.showScanHint
        scanHintView.iconView.image = .warning
        scanHintView.containerView.backgroundColor = .infoBackground
        scanHintView.containerView?.layer.borderColor = UIColor.infoAccent.cgColor
        scanHintView.titleLabel.attributedText = Constants.Text.scanHintTitle.styledAs(.header_3)
        scanHintView.bodyLabel.attributedText = Constants.Text.scanHintText.styledAs(.body)
        stackView.setCustomSpacing(.space_24, after: scanHintView)
        scanHintView.enableAccessibility(label: Constants.Text.scanHintTitle + Constants.Text.scanHintText, traits: .staticText)
        scanHintView.containerTopConstraint.constant = 0
    }

    private func setupImmunizationView() {
        immunizationContainerView.isHidden = viewModel.immunizationDetailsHidden
        guard !viewModel.immunizationDetailsHidden else { return }
        immunizationView.layoutMargins.left = .space_7
        immunizationView.layoutMargins.top = .space_24
        immunizationView.backgroundColor = .neutralWhite
        immunizationView.horizontalContainerStackView.alignment = .top
        immunizationView.bottomBorder.isHidden = true
        immunizationView.imageViewWidthConstraint.constant = 32
        immunizationView.updateView(image: viewModel.immunizationIcon,
                                    title: viewModel.immunizationTitle.styledAs(.header_3),
                                    body: viewModel.immunizationBody.styledAs(.body).colored(.onBackground70))
        immunizationView.layoutMargins.bottom = .space_24
        immunizationView.imageView.contentMode = .center
        immunizationButton.title = viewModel.immunizationButton
        immunizationButton.isHidden = true
        immunizationButton.action = { [weak self] in
            self?.viewModel.immunizationButtonTapped()
        }
        stackView.setCustomSpacing(.space_24, after: immunizationButtonContainerView)
    }

    private func setupReissueStackView() {
        reissueStackView.removeAllArrangedSubviews()
        if viewModel.showBoosterReissueNotification {
            let hintButton = createReissueHintButton()
            hintButton.button.action = viewModel.triggerBoosterReissue
            hintButton.titleLabel.attributedText = viewModel.boosterReissueNotificationTitle.styledAs(.header_3)
            hintButton.bodyTextView.attributedText = viewModel.boosterReissueNotificationBody.styledAs(.body)
            hintButton.button.title = viewModel.boosterReissueButtonTitle
            reissueStackView.addArrangedSubview(hintButton)
        } else if viewModel.showVaccinationExpiryReissueNotification {
            let hintButton = createReissueHintButton()
            hintButton.button.action = viewModel.triggerVaccinationExpiryReissue
            hintButton.titleLabel.attributedText = viewModel.reissueVaccinationTitle.styledAs(.header_3)
            hintButton.bodyTextView.attributedText = viewModel.vaccinationExpiryReissueNotificationBody.styledAs(.body)
            hintButton.button.title = viewModel.vaccinationExpiryReissueButtonTitle
            hintButton.hintButtonWrapper.isHidden = !viewModel.showVaccinationExpiryReissueButtonInNotification
            reissueStackView.addArrangedSubview(hintButton)
        }
        for index in 0 ..< viewModel.recoveryExpiryReissueCandidatesCount {
            let hintButton = createReissueHintButton()
            hintButton.button.action = { [weak self] in
                self?.viewModel.triggerRecoveryExpiryReissue(index: index)
            }
            hintButton.titleLabel.attributedText = viewModel.reissueRecoveryTitle(index: index).styledAs(.header_3)
            hintButton.bodyTextView.attributedText = viewModel.recoveryExpiryReissueNotificationBody(index: index).styledAs(.body)
            hintButton.button.title = viewModel.recoveryExpiryReissueButtonTitle
            hintButton.hintButtonWrapper.isHidden = !viewModel.showRecoveryExpiryReissueButtonInNotification(index: index)
            reissueStackView.addArrangedSubview(hintButton)
        }
        reissueStackView.isHidden = reissueStackView.arrangedSubviews.isEmpty
        stackView.setCustomSpacing(20, after: reissueStackView)
    }

    private func createReissueHintButton() -> HintButton {
        let reissueHintView = HintButton()
        reissueHintView.bodyTextView.backgroundColor = .clear
        reissueHintView.containerView.backgroundColor = .brandAccent20
        reissueHintView.containerView?.layer.borderColor = UIColor.brandAccent40.cgColor
        reissueHintView.button.style = .primary
        reissueHintView.backgroundColor = .backgroundPrimary
        return reissueHintView
    }

    private func setupBoosterHintView() {
        boosterHintView.isHidden = !viewModel.showBoosterNotification

        boosterHintView.iconView.image = nil
        boosterHintView.iconLabel.text = viewModel.boosterNotificationHighlightText
        boosterHintView.iconLabel.isHidden = !viewModel.showNewBoosterNotification
        boosterHintView.containerView.backgroundColor = .neutralWhite
        boosterHintView.containerView?.layer.borderColor = UIColor.neutralWhite.cgColor

        boosterHintView.titleLabel.attributedText = viewModel.boosterNotificationTitle.styledAs(.header_3)
        boosterHintView.bodyLabel.attributedText = viewModel.boosterNotificationBody.styledAs(.body)
        boosterHintView.bodyLabel.linkCallback = { [weak self] url in
            self?.viewModel.router.showWebview(url)
        }
    }

    private func setupPersonalData() {
        stackView.setCustomSpacing(.space_12, after: personalDataHeadline)
        personalDataHeadline.attributedText = viewModel.title.styledAs(.header_2)
        personalDataHeadline.textableView.accessibilityTraits = .header
        personalDataHeadline.layoutMargins = .init(top: .space_30, left: .space_24, bottom: .zero, right: .space_24)
        personalDataHeadline.textableView.accessibilityTraits = .header

        nameView.updateView(title: viewModel.nameTitle.styledAs(.header_3),
                            body: viewModel.nameReversed.styledAs(.body))
        nameView.accessibilityLabelValue = viewModel.accessibilityName
        nameView.contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)

        nameTransliteratedView.updateView(title: viewModel.nameTitleStandard.styledAs(.header_3),
                                          body: viewModel.nameTransliterated.styledAs(.body))
        nameTransliteratedView.accessibilityLabelValue = viewModel.accessibilityNameStandard
        nameTransliteratedView.contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)

        birtdateView.updateView(title: viewModel.dateOfBirth.styledAs(.header_3),
                                body: viewModel.birthDate.styledAs(.body))
        birtdateView.accessibilityLabelValue = viewModel.accessibilityDateOfBirth
        birtdateView.contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)
        birtdateView.accessibilityLabel = "\(viewModel.accessibilityDateOfBirth)\n \(DateUtils.audioDate(viewModel.birthDate) ?? viewModel.birthDate)"

        allCertificatesHeadline.attributedText = viewModel.certificatesTitle.styledAs(.header_2)
        allCertificatesHeadline.textableView.enableAccessibility(label: viewModel.accessibilityCertificatesTitle, traits: .header)
        allCertificatesHeadline.layoutMargins = .init(top: .space_30, left: .space_24, bottom: .space_16, right: .space_24)
        allCertificatesHeadline.textableView.accessibilityTraits = .header
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

private extension ParagraphView {
    func setup(with viewModel: CertificateHolderImmunizationStatusViewModelProtocol) {
        layoutMargins.top = .space_24
        layoutMargins.left = .space_7
        updateView(image: viewModel.icon,
                   title: viewModel.title.styledAs(.header_3),
                   subtitle: viewModel.subtitle?.styledAs(.header_3).colored(.onBackground80),
                   secondSubtitle: viewModel.federalStateText?.styledAs(.subheader_2).colored(.onBackground80),
                   body: viewModel.description.styledAs(.body).colored(.onBackground80),
                   footerButtonTitle: viewModel.selectFederalStateButtonTitle,
                   contentMode: .center)
    }
}
