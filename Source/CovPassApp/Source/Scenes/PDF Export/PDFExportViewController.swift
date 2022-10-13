//
//  PDFExportViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

private enum Constants {
    enum Accessibility {
        static let close = VoiceOverOptions.Settings(label: "accessibility_popup_label_close".localized)
    }
}

class PDFExportViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var exportExplanationsView: ParagraphView!
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
        setupView()
    }

    // MARK: - Private

    private func setupView() {
        configureHeadline()
        configureText()
        configureButtons()
    }

    private func configureHeadline() {
        headline.attributedTitleText = viewModel.title.styledAs(.header_2)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.actionButton.enableAccessibility(label: Constants.Accessibility.close.label)
        headline.layoutMargins.bottom = .space_24
    }

    private func configureText() {
        exportExplanationsView.updateView(body: viewModel.disclaimerText.styledAs(.body))
        exportExplanationsView.bottomBorder.isHidden = true
    }

    private func configureButtons() {
        exportButton.title = viewModel.exportButtonTitle
        exportButton.action = { [weak self] in
            DispatchQueue.main.async {
                self?.exportButton.startAnimating(makeCircle: true)

                // generate PDF and present share sheet
                self?.viewModel.generatePDF { [weak self] document in
                    guard let document = document else {
                        print("Could not generate PDF")
                        return
                    }

                    // create a temporary file to export
                    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

                    // Customize export name
                    var name = self?.viewModel.token.vaccinationCertificate.hcert.dgc.nam.fullName
                    name = name?.replacingOccurrences(of: " ", with: "-")
                    let fileName = "Certificate-\(name ?? "").pdf".sanitizedFileName
                    let pdfFile = temporaryDirectoryURL.appendingPathComponent(fileName)
                    document.write(to: pdfFile)

                    // present 'share sheet'
                    let activityViewController = UIActivityViewController(activityItems: [pdfFile], applicationActivities: nil)
                    activityViewController.completionWithItemsHandler = { _ /* type */, completed, _ /* returnedItems */, _ /* activityError */ in
                        // completion handler will be called even if we modify the PDF ('markup') and return to share sheet
                        // in that case we DON'T remove the pdf file
                        if activityViewController.view.superview == nil {
                            // cleanup
                            try? FileManager.default.removeItem(at: pdfFile)
                        }

                        // dismiss export view on successful export
                        if completed {
                            self?.dismiss(animated: true, completion: nil)
                        }
                    }
                    activityViewController.modalTransitionStyle = .coverVertical
                    self?.present(activityViewController, animated: true, completion: {
                        self?.exportButton.stopAnimating()
                    })
                }
            }
        }
        exportButton.layoutMargins = .init(top: 0, left: .space_24, bottom: 0, right: .space_24)
    }
}
