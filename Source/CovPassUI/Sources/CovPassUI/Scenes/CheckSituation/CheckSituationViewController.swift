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
    @IBOutlet weak var offlineRevocationTitleLabel: UILabel!
    @IBOutlet weak var offlineRevocationSwitch: LabeledSwitch!
    @IBOutlet weak var offlineRevocationDescriptionLabel: UILabel!

    // MARK: - Properties
    private(set) var viewModel: CheckSituationViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: CheckSituationViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
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
    
    fileprivate func configureTravelRulesSelection() {
        let travelRulesAttrbString = NSMutableAttributedString()
        travelRulesAttrbString.append(viewModel.travelRulesTitle.styledAs(.header_3))
        travelRulesAttrbString.append("\n".styledAs(.body))
        travelRulesAttrbString.append(viewModel.travelRulesDescription.styledAs(.body))
        optionOneTravel.textLabel.attributedText = travelRulesAttrbString
    }
    
    fileprivate func configureSaveButton() {
        saveButton.style = .primary
        saveButton.title = viewModel.doneButtonTitle
        saveButton.action = viewModel.doneIsTapped
    }
    
    fileprivate func configureHidden() {
        optionOneTravel.isHidden = viewModel.selectionIsHidden
        optionOneTravel.leftIcon.isHidden = true
        saveButton.isHidden = viewModel.buttonIsHidden
        subTitleTextWrapper.isHidden = viewModel.subTitleIsHidden
        newBadgeWrapper.isHidden = viewModel.newBadgeIconIsHidden
        pageImageView.isHidden = viewModel.pageImageIsHidden
        titleLabel.isHidden = viewModel.pageTitleIsHidden
    }
    
    fileprivate func configureImageView() {
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
        configureTravelRulesSelection()
        configureDomesticSelection()
        configureHidden()
        configureSaveButton()
        configureSpacings()
        configSelection()
        configureOfflineRevocationView()
    }

    private func configureOfflineRevocationView() {
        offlineRevocationView.isHidden = viewModel.offlineRevocationIsHidden
        offlineRevocationTitleLabel.attributedText = NSAttributedString(
            string: viewModel.offlineRevocationTitle
        )
        .font(named: UIFont.sansSemiBold, size: 18.0, lineHeight: 27.0, textStyle: .headline)
        .colored(.onBackground110)
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

extension CheckSituationViewController: ViewModelDelegate {
    public func viewModelDidUpdate() {
        configSelection()
    }
    
    public func viewModelUpdateDidFailWithError(_ error: Error) {}
}
