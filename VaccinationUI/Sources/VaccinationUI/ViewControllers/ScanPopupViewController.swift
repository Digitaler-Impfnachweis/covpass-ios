//
//  ProofPopupViewController.swift
//
//
//  Created by Daniel on 09.04.2021.
//

import UIKit
import BottomPopup
import Scanner

public class ScanPopupViewController: BottomPopupViewController {
    
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
        scanViewController = Scanner.viewController(codeTypes: [.qr], scanMode: .once, simulatedData: "This is Gabriela", delegate: self)
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

    public override var popupHeight: CGFloat { viewModel.height }
    public override var popupTopCornerRadius: CGFloat { viewModel.topCornerRadius }
    public override var popupPresentDuration: Double { viewModel.presentDuration }
    public override var popupDismissDuration: Double { viewModel.dismissDuration }
    public override var popupShouldDismissInteractivelty: Bool { viewModel.shouldDismissInteractivelty }
    public override var popupDimmingViewAlpha: CGFloat { 0.5 }
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
