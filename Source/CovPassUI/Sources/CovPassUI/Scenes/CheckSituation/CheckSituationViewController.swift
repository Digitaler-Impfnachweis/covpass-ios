//
//  CheckSituationViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import UIKit

public class CheckSituationViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var bottomStackView: UIStackView!
    @IBOutlet var stackview: UIStackView!
    @IBOutlet var descriptionLabel: PlainLabel!
    @IBOutlet var descriptionContainerView: UIView!
    @IBOutlet var updateStackview: UIStackView!
    @IBOutlet var bodyTitleLabel: PlainLabel!
    @IBOutlet var downloadStateHintLabel: PlainLabel!
    @IBOutlet var downloadStateIconImageView: UIImageView!
    @IBOutlet var downloadStateWrapper: UIView!
    @IBOutlet var certificateProviderStackView: UIStackView!
    @IBOutlet var certificateProviderTitleLabel: PlainLabel!
    @IBOutlet var certificateProviderSubtitleLabel: PlainLabel!
    @IBOutlet var authorityListStackView: UIStackView!
    @IBOutlet var authorityListView: UIView!
    @IBOutlet var authorityListDivider: UIView!
    @IBOutlet var authorityListTitleLabel: PlainLabel!
    @IBOutlet var authorityListSubtitleLabel: PlainLabel!
    @IBOutlet var ifsgTitleLabel: PlainLabel!
    @IBOutlet var ifsgSubtitleLabel: PlainLabel!
    @IBOutlet var cancelButton: MainButton!
    @IBOutlet var downloadingHintLabel: PlainLabel!
    @IBOutlet var activityIndicatorWrapper: UIView!
    @IBOutlet public var mainButton: MainButton!
    private let activityIndicator = DotPulseActivityIndicator(frame: CGRect(x: 0, y: 0, width: 100, height: 20))

    // MARK: - Properties

    private(set) var viewModel: CheckSituationViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: CheckSituationViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .uiBundle)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        configureView()
        configureAccessibilityRespondsToUserInteraction()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }

    private func configureUpdateEntriesStackViews() {
        certificateProviderStackView.isAccessibilityElement = true
        authorityListStackView.isAccessibilityElement = true
    }

    func configureView() {
        title = viewModel.navBarTitle
        view.backgroundColor = .backgroundPrimary

        let backButton = UIBarButtonItem(image: .arrowBack, style: .done, target: self, action: #selector(backButtonTapped))
        backButton.accessibilityLabel = "accessibility_app_information_contact_label_back".localized // TODO: change accessibility text when they are available
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .onBackground100

        descriptionLabel.attributedText = viewModel.footerText.styledAs(.body)
        configureUpdateEntriesStackViews()
        configureUpdateView()
    }

    private func configureAccessibilityRespondsToUserInteraction() {
        if #available(iOS 13.0, *) {
            descriptionLabel.accessibilityRespondsToUserInteraction = true
            bodyTitleLabel.accessibilityRespondsToUserInteraction = true
            downloadStateHintLabel.accessibilityRespondsToUserInteraction = true
            certificateProviderStackView.accessibilityRespondsToUserInteraction = true
            downloadingHintLabel.accessibilityRespondsToUserInteraction = true
            authorityListStackView.accessibilityRespondsToUserInteraction = true
        }
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension CheckSituationViewController {
    // MARK: - Private Methods for Update Context

    private func setupButtonActions() {
        mainButton.action = viewModel.refresh
        cancelButton.action = viewModel.cancel
    }

    private func setupStaticTexts() {
        mainButton.title = viewModel.offlineModusButton
        mainButton.style = .primary
        cancelButton.title = viewModel.cancelButtonTitle
        cancelButton.style = .plain
        certificateProviderTitleLabel.attributedText = viewModel.certificateProviderTitle.styledAs(.header_3)
        ifsgTitleLabel.attributedText = viewModel.ifsgTitle.styledAs(.header_3)
        authorityListTitleLabel.attributedText = viewModel.authorityListTitle.styledAs(.header_3)
        certificateProviderStackView.accessibilityLabel = viewModel.certificateProviderTitle
        downloadingHintLabel.attributedText = viewModel.loadingHintTitle.styledAs(.header_3).colored(.gray)
        bodyTitleLabel.attributedText = viewModel.listTitle.styledAs(.header_2)
        bodyTitleLabel.enableAccessibility(label: viewModel.listTitle, traits: .header)
    }

    private func configureUpdateView() {
        bottomStackView.isHidden = true
        setupActivityIndicator()
        setupButtonActions()
        updateUpdateRelatedViews()
        setupStaticTexts()
        downloadStateWrapper.layer.cornerRadius = 12.0
    }

    private func updateLoadingView(isLoading: Bool) {
        mainButton?.isHidden = isLoading
        downloadingHintLabel.isHidden = !isLoading
        cancelButton.isHidden = !isLoading
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorWrapper.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorWrapper.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo: activityIndicatorWrapper.topAnchor, constant: 40).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: activityIndicatorWrapper.bottomAnchor, constant: -40.0).isActive = true
        activityIndicator.leftAnchor.constraint(equalTo: activityIndicatorWrapper.leftAnchor, constant: 40.0).isActive = true
        activityIndicator.rightAnchor.constraint(equalTo: activityIndicatorWrapper.rightAnchor, constant: -40.0).isActive = true
    }

    private func updateUpdateRelatedViews() {
        updateStackview.isHidden = viewModel.updateContextHidden
        updateLoadingView(isLoading: viewModel.isLoading)
        downloadStateHintLabel.attributedText = viewModel.downloadStateHintTitle.styledAs(.label).colored(viewModel.downloadStateTextColor)
        downloadStateIconImageView.image = viewModel.downloadStateHintIcon
        downloadStateWrapper.backgroundColor = viewModel.downloadStateHintColor
        certificateProviderSubtitleLabel.attributedText = viewModel.certificateProviderSubtitle.styledAs(.body)
        certificateProviderStackView.accessibilityValue = viewModel.certificateProviderSubtitle
        ifsgSubtitleLabel.attributedText = viewModel.ifsgSubtitle.styledAs(.body)
        authorityListSubtitleLabel.attributedText = viewModel.authorityListSubtitle.styledAs(.body)
        authorityListStackView.accessibilityValue = viewModel.authorityListSubtitle
        authorityListView.isHidden = viewModel.authorityListIsHidden
        authorityListDivider.isHidden = viewModel.authorityListIsHidden
    }
}

extension CheckSituationViewController: ViewModelDelegate {
    public func viewModelDidUpdate() {
        updateUpdateRelatedViews()
    }

    public func viewModelUpdateDidFailWithError(_: Error) {}
}
