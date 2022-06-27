//
//  CheckSituationViewController.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassCommon

class CheckSituationViewController: UIViewController {
    
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

    // MARK: - Properties
    private(set) var viewModel: CheckSituationViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: CheckSituationViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .announcement, argument: viewModel.onboardingOpen)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    func viewModelDidUpdate() {
        configSelection()
    }
    
    func viewModelUpdateDidFailWithError(_ error: Error) {}
}
