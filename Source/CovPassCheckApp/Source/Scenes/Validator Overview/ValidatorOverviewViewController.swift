//
//  ValidatorOverviewViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation
import Scanner
import UIKit

class ValidatorOverviewViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headerView: InfoHeaderView!
    @IBOutlet var scanCard: ScanCardView!
    @IBOutlet var offlineCard: OfflineCardView!

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
        viewModel.updateTrustList()
        setupHeaderView()
        setupCardView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Methods

    private func setupHeaderView() {
        headerView.attributedTitleText = viewModel.title.styledAs(.header_2)
        headerView.image = .help
        headerView.action = { [weak self] in
            self?.viewModel.showAppInformation()
        }
    }

    private func setupCardView() {
        scanCard.titleLabel.attributedText = "validation_start_screen_scan_title".localized.styledAs(.header_1).colored(.backgroundSecondary)
        scanCard.textLabel.attributedText = "validation_start_screen_scan_message".localized.styledAs(.body).colored(.backgroundSecondary)
        scanCard.actionButton.title = "validation_start_screen_scan_action_button_title".localized
        scanCard.actionButton.action = { [weak self] in
            self?.viewModel.startQRCodeValidation()
        }

        offlineCard.titleLabel.attributedText = "validation_start_screen_offline_modus_title".localized.styledAs(.header_2)
        offlineCard.textLable.attributedText = "validation_start_screen_offline_modus_message".localized.styledAs(.body)
        offlineCard.infoLabel.attributedText = viewModel.offlineTitle.styledAs(.body)
        offlineCard.infoImageView.image = viewModel.offlineIcon
        offlineCard.dateLabel.attributedText = viewModel.offlineMessage.styledAs(.body).colored(.onBackground70)
        offlineCard.layoutMargins.bottom = .space_40
    }
}

extension ValidatorOverviewViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        setupCardView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}
