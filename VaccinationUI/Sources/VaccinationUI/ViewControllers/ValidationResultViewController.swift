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

    @IBOutlet public var toolbarView: CustomToolbarView!
    @IBOutlet public var headline: InfoHeaderView!
    @IBOutlet public var imageView: ConfirmView!
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
        imageView.kind = .custom(
            image: inputViewModel.icon,
            width: 150,
            height: 150
        )
        imageView.detail = nil
        imageView.imageView.contentMode = .scaleAspectFill
    }

    private func configureHeadline() {
        headline.headline.text = ""
        headline.action = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        headline.buttonImage = inputViewModel.closeButtonImage
    }

    private func configureParagraphView() {
        resultView.titleAttributedText = inputViewModel.resultTitle.toAttributedString(.h3)
        resultView.bodyAttributedText = inputViewModel.resultBody.toAttributedString(.body)

        nameView.titleAttributedText = inputViewModel.nameTitle?.toAttributedString(.h3)
        nameView.bodyAttributedText = inputViewModel.nameBody?.toAttributedString(.body)

        idView.titleAttributedText = inputViewModel.idTitle?.toAttributedString(.h3)
        idView.bodyAttributedText = inputViewModel.idBody?.toAttributedString(.body)
    }

    private func configureToolbarView() {
        toolbarView.shouldShowTransparency = true
        toolbarView.shouldShowGradient = false
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

