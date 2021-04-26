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
    
    // MARK: - Private
    
    public func setupHeaderView() {
        headerView.actionButton.imageEdgeInsets = viewModel.headerButtonInsets
        headerView.headline.text = viewModel?.title
        headerView.buttonImage = UIImage(named: "ega_help", in: UIConstants.bundle, compatibleWith: nil)
    }

    private func setupOther() {
        view.tintColor = UIConstants.BrandColor.brandAccent
        headerView.headline.text = viewModel?.title
    }
    
    // MARK: - Card View

    func setupCardView() {
        scanCard.actionButton.title = "Zertifikat scannen"
        scanCard.actionButton.action = presentPopup
        scanCard.cornerRadius = viewModel.continerCornerRadius

        offlineCard.infoImageView.image = UIImage(named: "warning", in: UIConstants.bundle, compatibleWith: nil)
        offlineCard.cornerRadius = viewModel.continerCornerRadius
    }
    
    func presentPopup() {
        router?.presentPopup(onTopOf: self)
    }
}

// MARK: - ScannerDelegate

extension ValidatorViewController: ScannerDelegate {
    public func result(with value: Result<String, ScanError>) {
        presentedViewController?.dismiss(animated: true, completion: nil)
        switch value {
        case .success(let payload):
            viewModel?.process(payload: payload)
        case .failure(let error):
            print("We have an error: \(error)")
        }
    }
}

// MARK: - StoryboardInstantiating

extension ValidatorViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return ValidatorPassConstants.Storyboard.Pass
    }
}
