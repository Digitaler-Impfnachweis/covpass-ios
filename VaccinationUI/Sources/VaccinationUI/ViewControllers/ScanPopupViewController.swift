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
    public var router: Router?
    
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
        toolbarView.shouldShowTransparency = true
        toolbarView.shouldShowGradient = false
        toolbarView.state = .cancel
        toolbarView.setUpLeftButton(leftButtonItem: .navigationArrow)
        toolbarView.delegate = self
    }

    public override var popupHeight: CGFloat { viewModel.height }
    public override var popupTopCornerRadius: CGFloat { viewModel.topCornerRadius }
    public override var popupPresentDuration: Double { viewModel.presentDuration }
    public override var popupDismissDuration: Double { viewModel.dismissDuration }
    public override var popupShouldDismissInteractivelty: Bool { viewModel.shouldDismissInteractivelty }
    public override var popupDimmingViewAlpha: CGFloat { 0.5 }
}

// MARK: - ScannerDelegate

extension ScanPopupViewController: ScannerDelegate {
    public func result(with value: Result<String, ScanError>) {
        print(value)
        scanViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CustomToolbarViewDelegate

extension ScanPopupViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            dismiss(animated: true, completion: nil)
        case .cancelButton:
            dismiss(animated: true, completion: nil)
            print("Hello")
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


