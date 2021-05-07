//
//  ValidationResultViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

public class ValidationResultViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var toolbarView: CustomToolbarView!
    @IBOutlet public var headline: InfoHeaderView!
    @IBOutlet public var imageContainerView: UIStackView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var resultView: ParagraphView!
    @IBOutlet public var nameView: ParagraphView!
    @IBOutlet public var errorView: ParagraphView!

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

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
        configureHeadline()
        configureParagraphView()
        configureToolbarView()
        updateViews()
    }

    // MARK: - Private

    private func updateViews() {
        imageView.image = viewModel.icon

        resultView.attributedTitleText = viewModel.resultTitle.styledAs(.header_1)
        resultView.attributedBodyText = viewModel.resultBody.styledAs(.body)

        nameView.attributedTitleText = viewModel.nameTitle?.styledAs(.header_3)
        nameView.attributedBodyText = viewModel.nameBody?.styledAs(.body)
        nameView.image = viewModel.nameIcon

        errorView.attributedTitleText = viewModel.errorTitle?.styledAs(.header_3)
        errorView.attributedBodyText = viewModel.errorBody?.styledAs(.body)
        errorView.image = viewModel.errorIcon
    }

    private func configureImageView() {

        stackView.setCustomSpacing(.space_24, after: imageContainerView)
    }

    private func configureHeadline() {
        headline.attributedTitleText = "".styledAs(.header_3)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = viewModel.closeButtonImage
        stackView.setCustomSpacing(.space_24, after: headline)
    }

    private func configureParagraphView() {
        stackView.setCustomSpacing(.space_24, after: resultView)
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

    public func viewModelUpdateDidFailWithError(_ error: Error) {}
}

// MARK: - CustomToolbarViewDelegate

extension ValidationResultViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
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
    public func canDismissModalViewController() -> Bool {
        viewModel.isCancellable()
    }

    public func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
