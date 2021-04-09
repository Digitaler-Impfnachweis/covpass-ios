//
//  ProofPopupViewController.swift
//  
//
//  Created by Daniel on 09.04.2021.
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
    
    public var viewModel: ProofPopupViewModel!
    public var router: Popup?

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
            image: viewModel.image,
            width: viewModel.imageWidth,
            height: viewModel.imageHeight
        )
        confirmView.detail = nil
        confirmView.imageView.contentMode = viewModel.imageContentMode
    }

    private func configureHeadline() {
        headline.headline.text = viewModel.title
        headline.headline.textColor = viewModel.headlineColor
        headline.action = {
            // Do Smth
        }
        headline.buttonImage = viewModel.closeButtonImage
        headline.headlineFont = viewModel.headlineFont
    }
    
    private func configureActionView() {
        actionView.headline.text = viewModel.actionTitle
        actionView.headline.textColor = viewModel.headlineColor
        actionView.action = {
            self.dismiss(animated: true, completion: nil)
        }
        actionView.buttonImage = viewModel.chevronRightImage
        actionView.headlineFont = viewModel.headlineFont
        actionView.leftMargin = 14
        actionView.tintColor = viewModel.tintColor
    }

    private func configureParagraphView() {
        paragraphView.title.isHidden = true
        paragraphView.bodyText = viewModel.info
        paragraphView.bodyFont = viewModel.paragraphBodyFont
    }
    
    private func configureToolbarView() {
        toolbarView.shouldShowTransparency = true
        toolbarView.shouldShowGradient = false
        toolbarView.state = .confirm(viewModel.startButtonTitle)
        toolbarView.setUpLeftButton(leftButtonItem: .navigationArrow)
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

extension ProofPopupViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            dismiss(animated: true, completion: nil)
        case .textButton:
            router?.presentPopup(onTopOf: self.presentingViewController ?? self)
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

