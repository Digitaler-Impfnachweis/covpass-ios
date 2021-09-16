//
//  ScanViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import AVFoundation
import Scanner
import UIKit

class ScanViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var toolbarView: CustomToolbarView!
    @IBOutlet var container: UIView!

    // MARK: - Properties

    private(set) var viewModel: ScanViewModel
    var scanViewController: ScannerViewController?

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ScanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
        container.backgroundColor = .neutralBlack

        configureToolbarView()

        viewModel.onCameraAccess = { [weak self] in
            self?.configureScanView()
        }
        viewModel.requestCameraAccess()
    }

    // MARK: - Private

    private func configureScanView() {
        let viewController = Scanner.viewController(codeTypes: [.qr], scanMode: .once, delegate: self)
        viewController.view.frame = container.bounds
        container.addSubview(viewController.view)
        viewController.view.pinEdges(to: container)
        scanViewController = viewController
    }

    private func configureToolbarView() {
        toolbarView.state = .cancel
        #if targetEnvironment(simulator)
            toolbarView.setUpRightButton(rightButtonItem: .flashLight)

        #else
            if viewModel.hasDeviceTorch {
                toolbarView.setUpRightButton(rightButtonItem: .flashLight)
            }
        #endif
        toolbarView.layoutMargins.top = .space_24
        toolbarView.delegate = self
        toolbarView.primaryButtonVoiceOverSettings = viewModel.closeVoiceOverOptions
        toolbarView.rightButtonVoiceOverSettings = viewModel.currentTorchVoiceOverOptions
    }
}

// MARK: - CustomToolbarViewDelegate

extension ScanViewController: CustomToolbarViewDelegate {
    func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .cancelButton:
            viewModel.cancel()
        case .flashLight:
            viewModel.toggleFlashlight()
            toolbarView.rightButtonVoiceOverSettings = viewModel.currentTorchVoiceOverOptions
        default:
            return
        }
    }
}

// MARK: - ScannerDelegate

extension ScanViewController: ScannerDelegate {
    func result(with value: Swift.Result<String, ScanError>) {
        viewModel.onResult(value)
    }
}

extension ScanViewController: ModalInteractiveDismissibleProtocol {
    func canDismissModalViewController() -> Bool {
        viewModel.isCancellable()
    }

    func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
