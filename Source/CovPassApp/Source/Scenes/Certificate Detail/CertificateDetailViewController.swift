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
        static let scanHintTitle = "certificates_start_screen_pop_up_app_reference_title".localized
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
        viewModel.markExpiryReissueCandidatesAsSeen()
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
    }

    private func setupNavigationBar() {
        title = ""
        navigationController?.navigationBar.backIndicatorImage = .arrowBack
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = .arrowBack
        navigationController?.navigationBar.tintColor = .onBackground100

        if viewModel.favoriteIcon != nil {
            let favoriteIcon = UIBarButtonItem(image: viewModel.favoriteIcon, style: .plain, target: self, action: #selector(toggleFavorite))
            favoriteIcon.tintColor = .onBackground100
            navigationItem.rightBarButtonItem = favoriteIcon
        }
    }

    private func setupHeadline() {
        nameHeadline.attributedText = viewModel.name.styledAs(.header_1).colored(.onBackground100)
        nameHeadline.textableView.accessibilityTraits = .header
        nameHeadline.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        nameHeadline.textableView.accessibilityTraits = .header
        stackView.setCustomSpacing(.space_24, after: nameHeadline)
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
        immunizationContainerView.layoutMargins.top = .space_24
        immunizationContainerView.layoutMargins.bottom = .space_24
        immunizationContainerView.backgroundColor = .neutralWhite
        immunizationView.stackView.alignment = .top
        immunizationView.bottomBorder.isHidden = true
        immunizationView.image = viewModel.immunizationIcon
        immunizationView.attributedTitleText = viewModel.immunizationTitle.styledAs(.header_3)
        immunizationView.attributedBodyText = viewModel.immunizationBody.styledAs(.body).colored(.onBackground70)
        immunizationView.layoutMargins.bottom = .space_24

        immunizationButton.title = viewModel.immunizationButton

        immunizationButton.action = { [weak self] in
            self?.viewModel.immunizationButtonTapped()
        }
        stackView.setCustomSpacing(.space_24, after: immunizationButtonContainerView)
    }
    
    private func setupReissueStackView() {
        reissueStackView.removeAllArrangedSubviews()
        if viewModel.showBoosterReissueNotification {
            let hintButton = createReissueHintButton()
            hintButton.topRightLabel.isHidden = !viewModel.showBoosterReissueIsNewBadge
            hintButton.button.action = viewModel.triggerBoosterReissue
            hintButton.titleLabel.attributedText = viewModel.boosterReissueNotificationTitle.styledAs(.header_3)
            hintButton.bodyTextView.attributedText = viewModel.boosterReissueNotificationBody.styledAs(.body)
            hintButton.button.title = viewModel.boosterReissueButtonTitle
            reissueStackView.addArrangedSubview(hintButton)
        } else if viewModel.showVaccinationExpiryReissueNotification {
            let hintButton = createReissueHintButton()
            hintButton.topRightLabel.isHidden = !viewModel.showVaccinationExpiryReissueIsNewBadge
            hintButton.button.action = viewModel.triggerVaccinationExpiryReissue
            hintButton.titleLabel.attributedText = viewModel.expiryReissueNotificationTitle.styledAs(.header_3)
            hintButton.bodyTextView.attributedText = viewModel.vaccinationExpiryReissueNotificationBody.styledAs(.body)
            hintButton.button.title = viewModel.vaccinationExpiryReissueButtonTitle
            reissueStackView.addArrangedSubview(hintButton)
        }
        for index in 0 ..< viewModel.recoveryExpiryReissueCandidatesCount {
            let hintButton = createReissueHintButton()
            hintButton.topRightLabel.isHidden = !viewModel.showRecoveryExpiryReissueIsNewBadge(index: index)
            hintButton.button.action = { [weak self] in
                self?.viewModel.triggerRecoveryExpiryReissue(index: index)
            }
            hintButton.titleLabel.attributedText = viewModel.expiryReissueNotificationTitle.styledAs(.header_3)
            hintButton.bodyTextView.attributedText = viewModel.recoveryExpiryReissueNotificationBody.styledAs(.body)
            hintButton.button.title = viewModel.recoveryExpiryReissueButtonTitle
            reissueStackView.addArrangedSubview(hintButton)
        }
        reissueStackView.isHidden = reissueStackView.arrangedSubviews.isEmpty
    }

    private func createReissueHintButton() -> HintButton {
        let reissueHintView = HintButton()
        reissueHintView.topRightLabel.text = viewModel.reissueNotificationHighlightText
        reissueHintView.containerView.backgroundColor = .neutralWhite
        reissueHintView.containerView?.layer.borderColor = UIColor.neutralWhite.cgColor
        reissueHintView.button.style = .alternative
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

        nameView.attributedTitleText = viewModel.nameTitle.styledAs(.header_3)
        nameView.accessibilityLabelValue = viewModel.accessibilityName
        nameView.attributedBodyText = viewModel.nameReversed.styledAs(.body)
        nameView.contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)

        nameTransliteratedView.attributedTitleText = viewModel.nameTitleStandard.styledAs(.header_3)
        nameTransliteratedView.attributedBodyText = viewModel.nameTransliterated.styledAs(.body)
        nameTransliteratedView.accessibilityLabelValue = viewModel.accessibilityNameStandard
        nameTransliteratedView.contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)

        birtdateView.attributedTitleText = viewModel.dateOfBirth.styledAs(.header_3)
        birtdateView.attributedBodyText = viewModel.birthDate.styledAs(.body)
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
