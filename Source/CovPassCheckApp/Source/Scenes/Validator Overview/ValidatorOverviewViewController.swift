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
        setupSegmentControl()
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
        headerView.textLabel.accessibilityTraits = .header
        headerView.image = .settings
        headerView.actionButtonWidth = 22.0
        headerView.action = { [weak self] in
            self?.viewModel.showAppInformation()
        }
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
    
    private func setupSegmentControl() {
        scanCard.switchWrapperViewIsHidden = true
        scanCard.actionButton.title = "validation_start_screen_scan_action_button_title".localized
        scanCard.actionButton.action = { [weak self] in
            self?.viewModel.startQRCodeValidation()
        }
        scanCard.updateAccessibility()
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
