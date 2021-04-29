//
//  ProofPopupViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import BottomPopup

public class ProofPopupViewController: BottomPopupViewController {
    // MARK: - IBOutlet
    
    @IBOutlet public var toolbarView: CustomToolbarView!
    @IBOutlet public var confirmView: ConfirmView!
    @IBOutlet public var headline: InfoHeaderView!
    @IBOutlet public var paragraphView: ParagraphView!
    @IBOutlet public var actionView: InfoHeaderView!
    
    // MARK: - Public Properties
    
    public var viewModel: BaseViewModel?
    public var router: PopupRouter?

    // MARK: - Internal Properties

    var inputViewModel: ProofPopupViewModel {
        viewModel as? ProofPopupViewModel ?? ProofPopupViewModel()
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
        configureHeadline()
        configureParagraphView()
        configureToolbarView()
        configureActionView()
    }

    // MARK: - Private

    private func configureImageView() {
        confirmView.kind = .custom(
            image: inputViewModel.image,
            width: inputViewModel.imageWidth,
            height: inputViewModel.imageHeight
        )
        confirmView.detail = nil
        confirmView.imageView.contentMode = inputViewModel.imageContentMode
    }

    private func configureHeadline() {
        headline.headline.text = inputViewModel.title
        headline.headline.textColor = inputViewModel.headlineColor
        headline.action = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        headline.buttonImage = inputViewModel.closeButtonImage
        headline.headlineFont = inputViewModel.headlineFont
    }
    
    private func configureActionView() {
        actionView.headline.text = inputViewModel.actionTitle
        actionView.headline.textColor = inputViewModel.headlineColor
        actionView.action = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        actionView.buttonImage = inputViewModel.chevronRightImage
        actionView.headlineFont = inputViewModel.headlineFont
        actionView.tintColor = inputViewModel.tintColor
    }

    private func configureParagraphView() {
        paragraphView.title.isHidden = true
        paragraphView.bodyText = inputViewModel.info
        paragraphView.bodyFont = inputViewModel.paragraphBodyFont
        paragraphView.layoutMargins.top = 10
    }
    
    private func configureToolbarView() {
        toolbarView.shouldShowTransparency = true
        toolbarView.shouldShowGradient = false
        toolbarView.state = .confirm(inputViewModel.startButtonTitle)
        toolbarView.setUpLeftButton(leftButtonItem: .navigationArrow)
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

extension ProofPopupViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            dismiss(animated: true, completion: nil)
        case .textButton:
            router?.presentPopup(onTopOf: self.presentingViewController?.presentingViewController ?? self)
        default:
            return
        }
    }
}

// MARK: - StoryboardInstantiating

extension ProofPopupViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return UIConstants.Storyboard.Onboarding
    }
}

