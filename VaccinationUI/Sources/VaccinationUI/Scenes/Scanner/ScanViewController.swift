//
//  ScanViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import Scanner

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
        toolbarView.layoutMargins.top = .space_24
        toolbarView.delegate = self
    }
}

// MARK: - CustomToolbarViewDelegate

extension ScanViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .cancelButton:
            viewModel.cancel()
        default:
            return
        }
    }
}

// MARK: - ScannerDelegate

extension ScanViewController: ScannerDelegate {
    public func result(with value: Swift.Result<String, ScanError>) {
        viewModel.onResult(value)
    }
}

extension ScanViewController: ModalInteractiveDismissibleProtocol {
    public func canDismissModalViewController() -> Bool {
        viewModel.isCancellable()
    }

    public func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
