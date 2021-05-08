//
//  ScanViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

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
        configureToolbarView()
        configureScanView()
    }

    // MARK: - Private

    private func configureScanView() {
        scanViewController = Scanner.viewController(codeTypes: [.qr], scanMode: .once, delegate: self)
        scanViewController?.view.frame = container.bounds
        container.addSubview(scanViewController!.view)
        scanViewController?.view.pinEdges(to: container)
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

extension ScanViewController: CustomToolbarViewDelegate {
    func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
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
