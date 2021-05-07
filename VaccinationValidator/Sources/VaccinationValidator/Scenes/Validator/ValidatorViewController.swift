//
//  ValidatorViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI
import Scanner

class ValidatorViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headerView: InfoHeaderView!
    @IBOutlet var scanCard: ScanCardView!
    @IBOutlet var offlineCard: OfflineCardView!

    // MARK: - Properties

    private(set) var viewModel: ValidatorViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ValidatorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
    }

    private func setupCardView() {
        scanCard.titleLabel.attributedText = "validation_start_screen_Scan_title".localized.styledAs(.header_1).colored(.backgroundSecondary)
        scanCard.textLabel.attributedText = "validation_start_screen_Scan_message".localized.styledAs(.body).colored(.backgroundSecondary)
        scanCard.actionButton.title = "validation_start_screen_Scan_action_button_title".localized
        scanCard.actionButton.action = { [weak self] in
            self?.viewModel.startQRCodeValidation()
        }

        offlineCard.titleLabel.attributedText = "validation_start_screen_offline_modus_title".localized.styledAs(.header_2)
        offlineCard.textLable.attributedText = "validation_start_screen_offline_modus_message".localized.styledAs(.body)
        offlineCard.infoLabel.attributedText = viewModel.offlineTitle.styledAs(.body)
        offlineCard.infoImageView.image = .warning
        offlineCard.dateLabel.attributedText = viewModel.offlineMessage.styledAs(.body).colored(.onBackground70)
    }
}
