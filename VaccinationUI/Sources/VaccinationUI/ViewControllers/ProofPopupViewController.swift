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
    @IBOutlet public var imageView: UIImageView!
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
        imageView.image = inputViewModel.image
        imageView.scaleAspectFit()
    }

    private func configureHeadline() {
        headline.attributedTitleText = inputViewModel.title.toAttributedString(.h4)
        headline.action = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        headline.image = inputViewModel.closeButtonImage
    }
    
    private func configureActionView() {
        actionView.attributedTitleText = inputViewModel.actionTitle.toAttributedString(.h5)
        actionView.action = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        actionView.image = inputViewModel.chevronRightImage
        actionView.tintColor = inputViewModel.tintColor
    }

    private func configureParagraphView() {
        paragraphView.attributedBodyText = inputViewModel.info.toAttributedString(.body)
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

