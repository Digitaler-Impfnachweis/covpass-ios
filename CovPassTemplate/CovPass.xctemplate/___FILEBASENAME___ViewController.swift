//
//  ___VARIABLE_moduleName___ViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassUI

class ___VARIABLE_moduleName___ViewController: UIViewController {

    // MARK: - Properties

    private(set) var viewModel: ___VARIABLE_moduleName___ViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ___VARIABLE_moduleName___ViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }

    // MARK: - Methods
    
    func updateView() {}
    
 }

extension ___VARIABLE_moduleName___ViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        updateView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {
        // already handled in ViewModel
    }
}
