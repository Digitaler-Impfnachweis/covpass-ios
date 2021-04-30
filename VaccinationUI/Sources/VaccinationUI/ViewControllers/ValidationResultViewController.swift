//
//  ValidationResultViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import BottomPopup

public class ValidationResultViewController: BottomPopupViewController {
    // MARK: - IBOutlet

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var toolbarView: CustomToolbarView!
    @IBOutlet public var headline: InfoHeaderView!
    @IBOutlet public var imageContainerView: UIStackView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var resultView: ParagraphView!
    @IBOutlet public var nameView: ParagraphView!
    @IBOutlet public var idView: ParagraphView!

    // MARK: - Public Properties

    public var viewModel: BaseViewModel?
    public var router: PopupRouter?

    // MARK: - Internal Properties

    var inputViewModel: ValidationResultViewModel {
        viewModel as? ValidationResultViewModel ?? ValidationResultViewModel(certificate: nil)
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
        configureHeadline()
        configureParagraphView()
        configureToolbarView()
    }

    // MARK: - Private

    private func configureImageView() {
        imageView.image = inputViewModel.icon
        stackView.setCustomSpacing(.space_24, after: imageContainerView)
    }

    private func configureHeadline() {
        headline.attributedTitleText = "".toAttributedString()
        headline.action = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        headline.image = inputViewModel.closeButtonImage
        stackView.setCustomSpacing(.space_24, after: headline)
    }

    private func configureParagraphView() {
        resultView.attributedTitleText = inputViewModel.resultTitle.toAttributedString(.header_1)
        resultView.attributedBodyText = inputViewModel.resultBody.toAttributedString(.body)
        stackView.setCustomSpacing(.space_24, after: resultView)

        nameView.image = .warning
        nameView.attributedTitleText = inputViewModel.nameTitle?.toAttributedString(.header_3)
        nameView.attributedBodyText = inputViewModel.nameBody?.toAttributedString(.body)

        idView.image = .card
        idView.attributedTitleText = inputViewModel.idTitle?.toAttributedString(.header_3)
        idView.attributedBodyText = inputViewModel.idBody?.toAttributedString(.body)
    }

    private func configureToolbarView() {
        toolbarView.state = .confirm("Nächstes Zertifikat scannen")
        toolbarView.delegate = self
    }

    public override var popupHeight: CGFloat { inputViewModel.height }
    public override var popupTopCornerRadius: CGFloat { inputViewModel.topCornerRadius }
    public override var popupPresentDuration: Double { inputViewModel.presentDuration }
    public override var popupDismissDuration: Double { inputViewModel.dismissDuration }
    public override var popupShouldDismissInteractivelty: Bool { inputViewModel.shouldDismissInteractivelty }
    public override var popupDimmingViewAlpha: CGFloat { 0.5 }
}

// MARK: - CustomToolbarViewDelegate

extension ValidationResultViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            dismiss(animated: true, completion: nil)
        case .textButton:
            let vc = self.presentingViewController
            dismiss(animated: true, completion: {
                self.router?.presentPopup(onTopOf: vc ?? self)
            })
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

