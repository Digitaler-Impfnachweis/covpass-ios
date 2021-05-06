//
//  ValidationResultViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

public class ValidationResultViewController: UIViewController, ViewModelDelegate {
    // MARK: - IBOutlet

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var toolbarView: CustomToolbarView!
    @IBOutlet public var headline: InfoHeaderView!
    @IBOutlet public var imageContainerView: UIStackView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var resultView: ParagraphView!
    @IBOutlet public var nameView: ParagraphView!
    @IBOutlet public var errorView: ParagraphView!

    // MARK: - Public Properties

    public var viewModel: ValidationResultViewModel!

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
        configureHeadline()
        configureParagraphView()
        configureToolbarView()
        updateViews()
    }

    public func viewModelDidUpdate() {
        updateViews()
    }

    public func viewModelUpdateDidFailWithError(_ error: Error) {
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
        headline.image = viewModel.closeButtonImage
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
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .textButton:
            viewModel.scanNextCertifcate()
        default:
            return
        }
    }
}

// MARK: - StoryboardInstantiating

extension ValidationResultViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return UIConstants.Storyboard.Onboarding
    }
}

extension ValidationResultViewController: ModalInteractiveDismissibleProtocol {
    public func canDismissModalViewController() -> Bool {
        viewModel.isCancellable()
    }

    public func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
