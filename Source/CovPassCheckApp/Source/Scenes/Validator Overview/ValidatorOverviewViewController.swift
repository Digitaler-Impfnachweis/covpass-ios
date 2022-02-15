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
    @IBOutlet var offlineCard: OfflineCardView!
    @IBOutlet var timeHintView: HintView!
    @IBOutlet var scanTypeSegment: UISegmentedControl!
    @IBOutlet var checkSituationLabel: UILabel!
    
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
        viewModel.showNotificationsIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.updateTrustList()
        viewModel.updateDCCRules()
        setupCheckSituationView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Methods

    private func setupHeaderView() {
        headerView.attributedTitleText = viewModel.title.styledAs(.header_2)
        headerView.textLabel.accessibilityTraits = .header
        headerView.image = .help
        headerView.action = { [weak self] in
            self?.viewModel.showAppInformation()
        }
    }

    private func setupCardView() {
        offlineCard.titleLabel.attributedText = "validation_start_screen_offline_modus_title".localized.styledAs(.header_2)
        offlineCard.textLable.attributedText = "validation_start_screen_offline_modus_message".localized.styledAs(.body)
        offlineCard.infoLabel.attributedText = viewModel.offlineTitle.styledAs(.body)
        offlineCard.infoImageView.image = viewModel.offlineIcon

        offlineCard.dateTitle.text = viewModel.updateTitle
        offlineCard.certificatesDateLabel.attributedText = viewModel.offlineMessageCertificates?.styledAs(.body).colored(.onBackground70)
        offlineCard.rulesDateLabel.attributedText = viewModel.offlineMessageRules?.styledAs(.body).colored(.onBackground70)

        offlineCard.layoutMargins.bottom = .space_40
        
        setupTimeHintView()
        setupCheckSituationView()
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
        scanCard.uiSwitch.isOn = viewModel.boosterAsTest
        scanCard.switchAction = { isOn in
            self.viewModel.boosterAsTest = isOn
        }
        scanCard.switchTextLabel.attributedText = viewModel.switchText.styledAs(.body).colored(.backgroundSecondary)
        scanCard.titleLabel.attributedText = viewModel.segment3GTitle.styledAs(.header_1).colored(.backgroundSecondary)
        scanCard.textLabel.attributedText = viewModel.segment3GMessage.styledAs(.body).colored(.backgroundSecondary)
        scanCard.actionButton.title = "validation_start_screen_scan_action_button_title".localized
        scanCard.actionButton.action = { [weak self] in
            guard let self = self else {
                return
            }
            guard let scanType = ScanType(rawValue: self.scanTypeSegment.selectedSegmentIndex) else {
                return
            }
            self.viewModel.startQRCodeValidation(for: scanType)
        }
        
        scanTypeSegment.setTitle(viewModel.segment3GTitle, forSegmentAt: ScanType._3G.rawValue)
        scanTypeSegment.setTitle(viewModel.segment2GTitle, forSegmentAt: ScanType._2G.rawValue)
    }
    
    private func setupCheckSituationView() {
        checkSituationLabel.attributedText = viewModel.checkSituationText.styledAs(.body).aligned(to: .center)
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch ScanType(rawValue:sender.selectedSegmentIndex) {
        case ._3G:
            scanCard.titleLabel.attributedText = viewModel.segment3GTitle.styledAs(.header_1).colored(.backgroundSecondary)
            scanCard.textLabel.attributedText = viewModel.segment3GMessage.styledAs(.body).colored(.backgroundSecondary)
            scanCard.switchWrapperViewIsHidden = true
        case ._2G:
            scanCard.titleLabel.attributedText = viewModel.segment2GTitle.styledAs(.header_1).colored(.backgroundSecondary)
            scanCard.textLabel.attributedText = viewModel.segment2GMessage.styledAs(.body).colored(.backgroundSecondary)
            scanCard.switchWrapperViewIsHidden = false
        default: break
        }
    }
    
}

extension ValidatorOverviewViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        setupCardView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}
