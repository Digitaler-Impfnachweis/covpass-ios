//
//  ValidationResultViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import BottomPopup

public class ValidationResultViewController: BottomPopupViewController, ViewModelDelegate {
    // MARK: - IBOutlet

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var toolbarView: CustomToolbarView!
    @IBOutlet public var headline: InfoHeaderView!
    @IBOutlet public var imageContainerView: UIStackView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var resultView: ParagraphView!
    @IBOutlet public var nameView: ParagraphView!

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
        nameView.image = .warning
    }

    private func configureToolbarView() {
        toolbarView.state = .confirm("Nächstes Zertifikat scannen")
        toolbarView.delegate = self
    }

    public override var popupHeight: CGFloat { viewModel.height }
    public override var popupTopCornerRadius: CGFloat { viewModel.topCornerRadius }
    public override var popupPresentDuration: Double { viewModel.presentDuration }
    public override var popupDismissDuration: Double { viewModel.dismissDuration }
    public override var popupShouldDismissInteractivelty: Bool { viewModel.shouldDismissInteractivelty }
    public override var popupDimmingViewAlpha: CGFloat { 0.5 }
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

