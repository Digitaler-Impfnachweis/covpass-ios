//
//  ValidatorOverviewViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import CovPassCommon
import Foundation
import Scanner
import UIKit

class ValidatorOverviewViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headerView: InfoHeaderView!
    @IBOutlet var scanCard: ScanCardView!
    @IBOutlet var timeHintView: HintView!
    @IBOutlet var offlineInformationView: UIView!
    @IBOutlet var offlineInformationStateWrapperView: UIView!
    @IBOutlet var offlineInformationTitleLabel: PlainLabel!
    @IBOutlet var offlineInformationStateImageView: UIImageView!
    @IBOutlet var offlineInformationStateTextLabel: PlainLabel!
    @IBOutlet var offlineInformationDescriptionLabel: PlainLabel!
    @IBOutlet var offlineInformationUpdateCellTitleLabel: PlainLabel!
    @IBOutlet var offlineInformationUpdateCellSubtitleLabel: PlainLabel!
    @IBOutlet var offlineInformationCellAccesoryImageView: UIImageView!
    @IBOutlet var offlineInformationUpdateContainer: UIView!
    @IBOutlet var offlineModusTopContainer: UIView!
    
    // MARK: - Properties

    private(set) var viewModel: ValidatorOverviewViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ValidatorOverviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundPrimary
        viewModel.delegate = self
        setupHeaderView()
        setupCardView()
        setupOfflineInformationView()
        viewModel.showNotificationsIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.updateTrustList()
        viewModel.updateDCCRules()
        viewModel.updateValueSets()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Methods

    private func setupHeaderView() {
        headerView.attributedTitleText = viewModel.title.styledAs(.header_2)
        let settingsImage: UIImage = .settings
        settingsImage.accessibilityLabel = "app_information_title".localized
        settingsImage.accessibilityTraits = .button
        headerView.image = settingsImage
        headerView.action = viewModel.showAppInformation
    }

    private func setScanButtonLoadingState() {
        if viewModel.isLoadingScan {
            scanCard.actionButton.startAnimating()
        } else {
            scanCard.actionButton.stopAnimating()
        }
    }
    
    private func setupCardView() {
        setScanButtonLoadingState()        
        setupTimeHintView()
        
        scanCard.actionButton.title = viewModel.scanActionTitle
        scanCard.actionButton.action = {
            self.viewModel.scanAction(additionalToken: nil)
        }
        scanCard.titleLabel.attributedText = viewModel.scanDropDownTitle
            .styledAs(.subheader_3)
            .colored(.neutralWhite)
        scanCard.textLabel.attributedText = viewModel.scanDropDownValue
            .styledAs(.body)
            .colored(.neutralWhite)
        scanCard.chooseAction = viewModel.chooseAction
        scanCard.chooseButton.innerButton.titleLabel?.text = nil
        scanCard.chooseButton.enableAccessibility(label: viewModel.scanDropDownTitle,
                                                          hint: viewModel.scanDropDownValue,
                                                          traits: .selected)

    }
    
    private func setupTimeHintView() {
        timeHintView.isHidden = viewModel.timeHintIsHidden
        timeHintView.iconView.image = viewModel.timeHintIcon
        timeHintView.iconLabel.text = ""
        timeHintView.iconLabel.isHidden = true
        timeHintView.titleLabel.attributedText = viewModel.timeHintTitle.styledAs(.header_3)
        timeHintView.bodyLabel.attributedText = viewModel.timeHintSubTitle.styledAs(.body)
        timeHintView.setConstraintsToEdge()
    }
    
    private func setupOfflineInformationView() {
        offlineInformationView.layer.cornerRadius = 8
        offlineInformationTitleLabel.attributedText = viewModel.offlineInformationTitle.styledAs(.header_3)
        offlineInformationStateImageView.image = viewModel.offlineInformationStateIcon
        offlineInformationStateWrapperView.backgroundColor = viewModel.offlineInformationStateBackgroundColor
        offlineInformationStateWrapperView.layer.cornerRadius = 12
        offlineInformationStateImageView.image = viewModel.offlineInformationStateIcon
        offlineInformationStateTextLabel.attributedText  = viewModel.offlineInformationStateText.styledAs(.label).colored(viewModel.offlineInformationStateTextColor)
        offlineInformationDescriptionLabel.attributedText = viewModel.offlineInformationDescription.styledAs(.body)
        offlineInformationUpdateCellTitleLabel.attributedText = viewModel.offlineInformationUpdateCellTitle.styledAs(.header_3)
        offlineInformationUpdateCellSubtitleLabel.attributedText = viewModel.offlineInformationUpdateCellSubtitle.styledAs(.body)
        offlineInformationCellAccesoryImageView.image = viewModel.offlineInformationCellIcon
        offlineInformationUpdateContainer.enableAccessibility(label: viewModel.offlineInformationUpdateCellTitle,
                                                              hint: viewModel.offlineInformationUpdateCellSubtitle,
                                                              traits: .button)
        let offlineInformationAccessibilityText = viewModel.offlineInformationTitle + " " + viewModel.offlineInformationStateText
        offlineModusTopContainer.enableAccessibility(label: offlineInformationAccessibilityText,
                                                     hint: viewModel.offlineInformationDescription,
                                                     traits: .staticText)
    }

    // MARK: - Actions

     @IBAction func routeToUpdateTapped(_ sender: Any) {
         viewModel.routeToRulesUpdate()
     }
}

extension ValidatorOverviewViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        setupCardView()
        setupOfflineInformationView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}
