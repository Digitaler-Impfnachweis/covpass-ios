//
//  ValidationResultViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

class ValidationResultViewController: UIViewController, ViewModelDelegate {
    // MARK: - IBOutlet

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var toolbarView: CustomToolbarView!
    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var imageContainerView: UIStackView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var resultView: ParagraphView!
    @IBOutlet var nameView: ParagraphView!
    @IBOutlet var errorView: ParagraphView!

    // MARK: - Properties

    private(set) var viewModel: ValidationResultViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ValidationResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
        self.viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
        configureHeadline()
        configureParagraphView()
        configureToolbarView()
        updateViews()
    }

    func viewModelDidUpdate() {
        updateViews()
    }

    func viewModelUpdateDidFailWithError(_ error: Error) {
        // TODO: Handle error
    }

    // MARK: - Private

    private func updateViews() {
        imageView.image = viewModel.icon

        resultView.attributedTitleText = viewModel.resultTitle.styledAs(.header_1)
        resultView.attributedBodyText = viewModel.resultBody.styledAs(.body)

        nameView.attributedTitleText = viewModel.nameTitle?.styledAs(.header_3)
        nameView.attributedBodyText = viewModel.nameBody?.styledAs(.body)

        errorView.attributedTitleText = viewModel.errorTitle?.styledAs(.header_3)
        errorView.attributedBodyText = viewModel.errorBody?.styledAs(.body)
    }

    private func configureImageView() {

        stackView.setCustomSpacing(.space_24, after: imageContainerView)
    }

    private func configureHeadline() {
        headline.attributedTitleText = "".styledAs(.header_3)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        stackView.setCustomSpacing(.space_24, after: headline)
    }

    private func configureParagraphView() {
        stackView.setCustomSpacing(.space_24, after: resultView)
        nameView.image = .data
    }

    private func configureToolbarView() {
        toolbarView.state = .confirm("validation_check_popup_valid_vaccination_button_title".localized)
        toolbarView.delegate = self
    }
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
