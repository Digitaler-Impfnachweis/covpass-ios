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

public class ValidatorViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet public var headerView: InfoHeaderView!
    @IBOutlet public var scanCard: ScanCardView!
    @IBOutlet public var offlineCard: OfflineCardView!
    
    // MARK: - Public

    public var viewModel: ValidatorViewModel!
    
    // MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupCardView()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Private
    
    public func setupHeaderView() {
        headerView.attributedTitleText = viewModel?.title.styledAs(.header_2)
        headerView.image = .help
    }
    
    // MARK: - Card View

    func setupCardView() {
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

// MARK: - StoryboardInstantiating

extension ValidatorViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        "Validator"
    }
}
