//
//  PDFExportViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class PDFExportViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headline: InfoHeaderView!
    // ...
    @IBOutlet var exportButton: MainButton!

    // MARK: - Properties

    private(set) var viewModel: PDFExportViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: PDFExportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeadline()
        // TODO: text
        configureButtons()
    }

    // MARK: - Private

    private func configureHeadline() {
        headline.attributedTitleText = viewModel.title.styledAs(.header_2)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.layoutMargins.bottom = .space_24
    }

    private func configureButtons() {
        exportButton.title = viewModel.exportButtonTitle
        exportButton.action = { [weak self] in
            // generate ODF and present share sheet
            self?.viewModel.generatePDF()
        }
    }
}
