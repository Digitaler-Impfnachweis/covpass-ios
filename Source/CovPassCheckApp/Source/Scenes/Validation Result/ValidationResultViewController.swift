//
//  ValidationResultViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class ValidationResultViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var toolbarView: CustomToolbarView!
    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var imageContainerView: UIStackView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var resultView: ParagraphView!
    @IBOutlet var paragraphStackView: UIStackView!
    @IBOutlet var infoView: PlainLabel!

    // MARK: - Properties

    private(set) var viewModel: ValidationResultViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ValidationResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
        self.viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeadline()
        configureToolbarView()
        updateViews()
    }

    // MARK: - Private

    private func updateViews() {
        stackView.setCustomSpacing(.space_24, after: imageContainerView)
        stackView.setCustomSpacing(.space_24, after: resultView)

        imageView.image = viewModel.icon

        resultView.attributedTitleText = viewModel.resultTitle.styledAs(.header_1)
        resultView.attributedBodyText = viewModel.resultBody.styledAs(.body)

        infoView.attributedText = viewModel.info?.styledAs(.body).colored(.onBackground40)

        paragraphStackView.subviews.forEach {
            $0.removeFromSuperview()
            self.paragraphStackView.removeArrangedSubview($0)
        }
        viewModel.paragraphs.forEach {
            let p = ParagraphView()
            p.attributedTitleText = $0.title.styledAs(.header_3)
            p.attributedBodyText = $0.subtitle.styledAs(.body)
            p.image = $0.icon
            self.paragraphStackView.addArrangedSubview(p)
        }
    }

    private func configureHeadline() {
        headline.attributedTitleText = "".styledAs(.header_3)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        stackView.setCustomSpacing(.space_24, after: headline)
    }

    private func configureToolbarView() {
        toolbarView.state = .confirm("validation_check_popup_valid_vaccination_button_title".localized)
        toolbarView.delegate = self
    }
}

// MARK: - ViewModelDelegate

extension ValidationResultViewController: ViewModelDelegate {
    public func viewModelDidUpdate() {
        updateViews()
    }

    public func viewModelUpdateDidFailWithError(_: Error) {}
}

// MARK: - CustomToolbarViewDelegate

extension ValidationResultViewController: CustomToolbarViewDelegate {
    func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .textButton:
            viewModel.scanNextCertifcate()
        default:
            return
        }
    }
}

// MARK: - ModalInteractiveDismissibleProtocol

extension ValidationResultViewController: ModalInteractiveDismissibleProtocol {
    func canDismissModalViewController() -> Bool {
        viewModel.isCancellable()
    }

    func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
