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
        scanCard.titleLabel.attributedText = "Impfschutz prüfen".styledAs(.header_1).colored(.backgroundSecondary)
        scanCard.textLabel.attributedText = "Scannen Sie jetzt das Prüfzertifikat. Sie sehen sofort ob die Person geimpft ist.".styledAs(.body).colored(.backgroundSecondary)
        scanCard.actionButton.title = "Zertifikat scannen"
        scanCard.actionButton.action = { [weak self] in
            self?.viewModel.startQRCodeValidation()
        }

        offlineCard.titleLabel.attributedText = "Offline-Modus".styledAs(.header_2)
        offlineCard.textLable.attributedText = "Um offline prüfen zu können, halten Sie die App auf dem aktuellsten Stand. Stellen Sie dafür ab und an eine Verbindung mit dem Internet her.".styledAs(.body)
        offlineCard.infoLabel.attributedText = "Aktualisieren Sie die App".styledAs(.body)
        offlineCard.infoImageView.image = .warning
        offlineCard.dateLabel.attributedText = "Letztes Update: 01.01.1971, 05:36".styledAs(.body).colored(.onBackground70)
    }
}

// MARK: - StoryboardInstantiating

extension ValidatorViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return ValidatorPassConstants.Storyboard.Pass
    }
}
