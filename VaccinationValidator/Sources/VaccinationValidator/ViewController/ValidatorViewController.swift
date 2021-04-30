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
    public var router: PopupRouter?
    
    // MARK: - Fifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupOther()
        setupOther()
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
        headerView.actionButton.imageEdgeInsets = viewModel.headerButtonInsets
        headerView.attributedTitleText = viewModel?.title.toAttributedString(.h4)
        headerView.image = .help
    }

    private func setupOther() {
        view.tintColor = .brandAccent
        headerView.attributedTitleText = viewModel?.title.toAttributedString(.h4)
    }
    
    // MARK: - Card View

    func setupCardView() {
        scanCard.actionButton.title = "Zertifikat scannen"
        scanCard.actionButton.action = presentPopup
        scanCard.cornerRadius = viewModel.continerCornerRadius

        offlineCard.infoImageView.image = .warning
        offlineCard.cornerRadius = viewModel.continerCornerRadius
        offlineCard.dateLabel.attributedText = "Letztes Update: 01.01.1971, 05:36".toAttributedString(.body)
        offlineCard.dateLabel.textColor = UIConstants.BrandColor.onBackground100
    }
    
    func presentPopup() {
        router?.presentPopup(onTopOf: self)
    }
}

// MARK: - ScannerDelegate

extension ValidatorViewController: ScannerDelegate {
    public func result(with value: Result<String, ScanError>) {
        presentedViewController?.dismiss(animated: true, completion: {
            switch value {
            case .success(let payload):
                self.viewModel?.process(payload: payload).done({ cert in
                    let vc = ValidationResultViewController.createFromStoryboard()
                    vc.viewModel = ValidationResultViewModel(certificate: cert)
                    vc.router = ValidatorPopupRouter()
                    self.present(vc, animated: true, completion: nil)
                }).catch({ error in
                    print(error)
                })
            case .failure(let error):
                print("We have an error: \(error)")
            }
        })
    }
}

// MARK: - StoryboardInstantiating

extension ValidatorViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return ValidatorPassConstants.Storyboard.Pass
    }
}
