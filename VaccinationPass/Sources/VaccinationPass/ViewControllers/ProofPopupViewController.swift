//
//  ProofPopupViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import BottomPopup
import VaccinationUI

public class ProofPopupViewController: BottomPopupViewController {
    // MARK: - IBOutlet
    
    @IBOutlet public var toolbarView: CustomToolbarView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var headline: InfoHeaderView!
    @IBOutlet public var descriptionText: ParagraphView!
    @IBOutlet public var actionView: InfoHeaderView!

    // MARK: - Internal Properties

    public var viewModel: ProofPopupViewModel!

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
        configureHeadline()
        configureDescriptionText()
        configureToolbarView()
        configureActionView()
    }

    // MARK: - Private

    private func configureImageView() {
        imageView.image = viewModel.image
        imageView.pinHeightToScaleAspectFit()
    }

    private func configureHeadline() {
        headline.attributedTitleText = viewModel.title.styledAs(.header_2)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = viewModel.closeButtonImage
    }
    
    private func configureActionView() {
        actionView.attributedTitleText = viewModel.actionTitle.styledAs(.header_3)
        actionView.action = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        actionView.image = viewModel.chevronRightImage
        actionView.tintColor = viewModel.tintColor
        actionView.layoutMargins.top = .space_40
    }

    private func configureDescriptionText() {
        descriptionText.attributedBodyText = viewModel.info.styledAs(.body)
        descriptionText.layoutMargins.top = .space_18
        descriptionText.layoutMargins.bottom = .space_40
    }
    
    private func configureToolbarView() {
        toolbarView.state = .confirm(viewModel.startButtonTitle)
        toolbarView.setUpLeftButton(leftButtonItem: .navigationArrow)
        toolbarView.layoutMargins.top = .space_24
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
            viewModel.cancel()
        case .textButton:
            viewModel.done()
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