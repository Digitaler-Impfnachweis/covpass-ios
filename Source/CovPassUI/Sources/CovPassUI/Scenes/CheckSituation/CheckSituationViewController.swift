//
//  CheckSituationViewController.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassCommon

public class CheckSituationViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet var stackview: UIStackView!
    @IBOutlet var hStackView: UIStackView!
    @IBOutlet var titleLabel: PlainLabel!
    @IBOutlet var situationCheckTitleLabel: UILabel!
    @IBOutlet var newBadgeView: HighlightLabel!
    @IBOutlet var newBadgeWrapper: UIView!
    @IBOutlet var descriptionTextWrapper: UIView!
    @IBOutlet var subTitleTextWrapper: UIView!
    @IBOutlet var pageImageView: UIImageView!
    @IBOutlet var optionOneTravel: CountryItemView!
    @IBOutlet var optionTwoDomestic: CountryItemView!
    @IBOutlet var descriptionLabel: PlainLabel!
    @IBOutlet var subTitleLabel: PlainLabel!
    @IBOutlet var saveButton: MainButton!
    @IBOutlet var offlineRevocationView: UIView!
    @IBOutlet var offlineRevocationTitleLabel: UILabel!
    @IBOutlet var offlineRevocationSwitch: LabeledSwitch!
    @IBOutlet var offlineRevocationDescriptionLabel: UILabel!
    @IBOutlet var updateStackview: UIStackView!
    @IBOutlet var bodyTitleLabel: PlainLabel!
    @IBOutlet var downloadStateHintLabel: PlainLabel!
    @IBOutlet var downloadStateIconImageView: UIImageView!
    @IBOutlet var downloadStateWrapper: UIView!
    @IBOutlet var entryRulesTitleLabel: PlainLabel!
    @IBOutlet var entryRulesSubtitleLabel: PlainLabel!
    @IBOutlet var domesticRulesTitleLabel: PlainLabel!
    @IBOutlet var domesticRulesSubtitleLabel: PlainLabel!
    @IBOutlet var valueSetsTitleLabel: PlainLabel!
    @IBOutlet var valueSetsSubtitleLabel: PlainLabel!
    @IBOutlet var certificateProviderTitleLabel: PlainLabel!
    @IBOutlet var certificateProviderSubtitleLabel: PlainLabel!
    @IBOutlet var countryListTitleLabel: PlainLabel!
    @IBOutlet var countryListSubtitleLabel: PlainLabel!
    @IBOutlet var authorityListView: UIView!
    @IBOutlet var authorityListDivider: UIView!
    @IBOutlet var authorityListTitleLabel: PlainLabel!
    @IBOutlet var authorityListSubtitleLabel: PlainLabel!
    @IBOutlet var cancelButton: MainButton!
    @IBOutlet var downloadingHintLabel: PlainLabel!
    @IBOutlet var activityIndicatorWrapper: UIView!
    @IBOutlet public var mainButton: MainButton!
    private let activityIndicator = DotPulseActivityIndicator(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    
    // MARK: - Properties
    private(set) var viewModel: CheckSituationViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required public init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: CheckSituationViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .uiBundle)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        configureView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .announcement, argument: viewModel.onboardingOpen)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIAccessibility.post(notification: .announcement, argument: viewModel.onboardingClose)
    }
    
    private func configureDomesticSelection() {
        let domesticRulesAttrbString = NSMutableAttributedString()
        domesticRulesAttrbString.append(viewModel.domesticRulesTitle.styledAs(.header_3))
        domesticRulesAttrbString.append("\n".styledAs(.body))
        domesticRulesAttrbString.append(viewModel.domesticRulesDescription.styledAs(.body))
        optionTwoDomestic.textLabel.attributedText = domesticRulesAttrbString
        optionTwoDomestic.isHidden = viewModel.selectionIsHidden
        optionTwoDomestic.leftIcon.isHidden = true
        stackview.setCustomSpacing(40, after: optionTwoDomestic)
    }
    
    private func configureTravelRulesSelection() {
        let travelRulesAttrbString = NSMutableAttributedString()
        travelRulesAttrbString.append(viewModel.travelRulesTitle.styledAs(.header_3))
        travelRulesAttrbString.append("\n".styledAs(.body))
        travelRulesAttrbString.append(viewModel.travelRulesDescription.styledAs(.body))
        optionOneTravel.textLabel.attributedText = travelRulesAttrbString
    }
    
    private func configureSaveButton() {
        saveButton.style = .primary
        saveButton.title = viewModel.doneButtonTitle
        saveButton.action = viewModel.doneIsTapped
    }
    
    private func configureHidden() {
        optionOneTravel.isHidden = viewModel.selectionIsHidden
        optionOneTravel.leftIcon.isHidden = true
        saveButton.isHidden = viewModel.buttonIsHidden
        subTitleTextWrapper.isHidden = viewModel.subTitleIsHidden
        hStackView.isHidden = viewModel.hStackViewIsHidden
        newBadgeWrapper.isHidden = viewModel.newBadgeIconIsHidden
        pageImageView.isHidden = viewModel.pageImageIsHidden
        titleLabel.isHidden = viewModel.pageTitleIsHidden
    }
    
    private func configureImageView() {
        pageImageView.image = viewModel.pageImage
        pageImageView.enableAccessibility(label: viewModel.onboardingImageDescription, traits: .image)
    }
    
    private func configureSpacings() {
        if viewModel.descriptionTextIsTop {
            stackview.removeArrangedSubview(descriptionTextWrapper)
            stackview.insertArrangedSubview(descriptionTextWrapper, at: 0)
        }
        stackview.setCustomSpacing(24, after: descriptionTextWrapper)
        stackview.setCustomSpacing(28, after: hStackView)
        stackview.setCustomSpacing(44, after: pageImageView)
    }
    
    func configureView() {
        title = viewModel.navBarTitle
        view.backgroundColor = .backgroundPrimary
        titleLabel.attributedText = viewModel.pageTitle.styledAs(.header_2)
        newBadgeView.attributedText = viewModel.newBadgeText.styledAs(.label).colored(.white)
        descriptionLabel.attributedText = viewModel.footerText.styledAs(.body)
        subTitleLabel.attributedText = viewModel.subTitleText.styledAs(.header_3)
        configureImageView()
        situationCheckTitleLabel.attributedText = viewModel.situationChcekTitle.styledAs(.header_2)
        situationCheckTitleLabel.isHidden = viewModel.situationChcekTitleLabelHidden
        configureTravelRulesSelection()
        configureDomesticSelection()
        configureHidden()
        configureSaveButton()
        configureSpacings()
        configSelection()
        configureOfflineRevocationView()
        configureUpdateView()
    }

    private func configureOfflineRevocationView() {
        offlineRevocationView.isHidden = viewModel.offlineRevocationIsHidden
        offlineRevocationTitleLabel.attributedText = viewModel.offlineRevocationTitle.styledAs(.header_2)
        offlineRevocationDescriptionLabel.attributedText = viewModel.offlineRevocationDescription
            .styledAs(.body)
            .colored(.onBackground110)
        offlineRevocationSwitch.label.attributedText = viewModel.offlineRevocationSwitchTitle
            .styledAs(.header_3)
            .colored(.onBackground110)
        offlineRevocationSwitch.uiSwitch.onTintColor = .brandAccent
        offlineRevocationSwitch.switchChanged = { [weak self] _ in
            self?.viewModel.toggleOfflineRevocation()
        }
        offlineRevocationSwitch.uiSwitch.isOn = viewModel.offlineRevocationIsEnabled
        offlineRevocationSwitch.updateAccessibility()
    }
    
    func configSelection() {
        switch viewModel.selectedRule {
        case .eu:
            optionOneTravel.rightIcon.image = .checkboxChecked
            optionTwoDomestic.rightIcon.image = .checkboxUnchecked
        case .de:
            optionOneTravel.rightIcon.image = .checkboxUnchecked
            optionTwoDomestic.rightIcon.image = .checkboxChecked
        default:
            break
        }
        optionOneTravel.action = {
            self.viewModel.selectedRule = .eu
        }
        optionTwoDomestic.action = {
            self.viewModel.selectedRule = .de
        }
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
        entryRulesTitleLabel.attributedText = viewModel.entryRulesTitle.styledAs(.header_3)
        domesticRulesTitleLabel.attributedText = viewModel.domesticRulesUpdateTitle.styledAs(.header_3)
        valueSetsTitleLabel.attributedText = viewModel.valueSetsTitle.styledAs(.header_3)
        certificateProviderTitleLabel.attributedText = viewModel.certificateProviderTitle.styledAs(.header_3)
        countryListTitleLabel.attributedText = viewModel.countryListTitle.styledAs(.header_3)
        authorityListTitleLabel.attributedText = viewModel.authorityListTitle.styledAs(.header_3)
        downloadingHintLabel.attributedText = viewModel.loadingHintTitle.styledAs(.header_3).colored(.gray)
        bodyTitleLabel.attributedText = viewModel.listTitle.styledAs(.header_2)
    }
    
    private func configureUpdateView() {
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
        entryRulesSubtitleLabel.attributedText = viewModel.entryRulesSubtitle.styledAs(.body)
        domesticRulesSubtitleLabel.attributedText = viewModel.domesticRulesUpdateSubtitle.styledAs(.body)
        valueSetsSubtitleLabel.attributedText = viewModel.valueSetsSubtitle.styledAs(.body)
        certificateProviderSubtitleLabel.attributedText = viewModel.certificateProviderSubtitle.styledAs(.body)
        countryListSubtitleLabel.attributedText = viewModel.countryListSubtitle.styledAs(.body)
        authorityListSubtitleLabel.attributedText =
        viewModel.authorityListSubtitle.styledAs(.body)
        authorityListView.isHidden = !offlineRevocationSwitch.uiSwitch.isOn
        authorityListDivider.isHidden = !offlineRevocationSwitch.uiSwitch.isOn
    }
}


extension CheckSituationViewController: ViewModelDelegate {
    public func viewModelDidUpdate() {
        configSelection()
        updateUpdateRelatedViews()
    }
    
    public func viewModelUpdateDidFailWithError(_ error: Error) {}
}
