//
//  ProofViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

class ProofViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet public var headline: InfoHeaderView!
    @IBOutlet public var descriptionText: ParagraphView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var actionView: InfoHeaderView!
    @IBOutlet public var toolbarView: CustomToolbarView!

    // MARK: - Properties

    private(set) var viewModel: ProofViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ProofViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
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
}

// MARK: - CustomToolbarViewDelegate

extension ProofViewController: CustomToolbarViewDelegate {
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

// MARK: - ModalInteractiveDismissibleProtocol

extension ProofViewController: ModalInteractiveDismissibleProtocol {
    public func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
