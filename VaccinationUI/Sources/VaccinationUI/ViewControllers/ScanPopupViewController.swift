//
//  ProofPopupViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import Scanner

public class ScanPopupViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet public var toolbarView: CustomToolbarView!
    @IBOutlet public var continer: UIView!
    
    // MARK: - Public Properties
    
    public var viewModel: ScanPopupViewModel!
    
    // MARK: - Internal
    
    var scanViewController: ScannerViewController?

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureToolbarView()
        configureScanView()
    }

    // MARK: - Private

    private func configureScanView() {
        scanViewController = Scanner.viewController(codeTypes: [.qr], scanMode: .once, delegate: self)
        scanViewController?.view.frame = continer.bounds
        continer.addSubview(scanViewController!.view)
    }
    
    private func configureToolbarView() {
        toolbarView.state = .cancel
        // Comment out for now. We need to update the routing to make this work.
//        toolbarView.setUpLeftButton(leftButtonItem: .navigationArrow)
        toolbarView.layoutMargins.top = .space_24
        toolbarView.delegate = self
    }
}

// MARK: - CustomToolbarViewDelegate

extension ScanPopupViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            viewModel.cancel()
        case .cancelButton:
            viewModel.cancel()
        default:
            return
        }
    }
}

// MARK: - StoryboardInstantiating

extension ScanPopupViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return UIConstants.Storyboard.Onboarding
    }
}

// MARK: - ScannerDelegate

extension ScanPopupViewController: ScannerDelegate {
    public func result(with value: Swift.Result<String, ScanError>) {
        viewModel.onResult(value)
    }
}
