//
//  RevocationInfoViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassCommon

private enum Constants {
    enum Accessibility {
        static let close = VoiceOverOptions.Settings(label: "accessibility_popup_label_close".localized(bundle: .main))
    }
}

public class RevocationInfoViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet public var headerView: InfoHeaderView!
    @IBOutlet public var exportButton: MainButton!
    @IBOutlet public var stackView: UIStackView!

    // MARK: - Properties
    private var viewModel: RevocationInfoViewModelProtocol

    // MARK: - Lifecycle
    @available(*, unavailable)
    public required init?(coder _: NSCoder) { nil }

    public init(viewModel: RevocationInfoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .module)
        self.viewModel.delegate = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureHeadline()
        configureList()
        configureButton()
    }

    // MARK: - Private

    private func configureHeadline() {
        headerView.attributedTitleText = viewModel.title.styledAs(.header_2)
        headerView.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headerView.image = .close
        headerView.actionButton.enableAccessibility(label: Constants.Accessibility.close.label)
        headerView.layoutMargins.bottom = .space_24
    }

    private func configureList() {
        let views = viewModel.infoItems.map(ParagraphView.from)
        views.forEach(stackView.addArrangedSubview(_:))
    }

    private func configureButton() {
        exportButton.title = viewModel.buttonTitle
        exportButton.action = { [weak self] in
            self?.viewModel.createPDF()
        }
        exportButton.layoutMargins = .init(top: 0, left: .space_24, bottom: 0, right: .space_24)
        exportButton.isEnabled = viewModel.enableCreatePDF
    }

    private func refresh() {
        if viewModel.isGeneratingPDF {
            exportButton.startAnimating()
        } else {
            exportButton.stopAnimating()
        }
    }
}

extension RevocationInfoViewController: ViewModelDelegate {
    public func viewModelDidUpdate() {
        refresh()
    }

    public func viewModelUpdateDidFailWithError(_ error: Error) {
        refresh()
    }
}

private extension ParagraphView {
    static func from(_ item: ListContentItem) -> ParagraphView {
        let view = ParagraphView()
        view.updateView(title: item.label.styledAs(.header_3),
                        body: item.value.styledAs(.body))
        view.accessibilityLabel = item.accessibilityLabel
        view.accessibilityIdentifier = item.accessibilityIdentifier
        view.layoutMargins.top = .space_12

        return view
    }
}
