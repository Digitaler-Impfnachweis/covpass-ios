//
//  ProofViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

private enum Constants {
    enum Accessibility {
        static let image = VoiceOverOptions.Settings(label: "accessibility_image_alternative_text".localized)
        static let close = VoiceOverOptions.Settings(label: "accessibility_certificate_add_dialog_camera_access_label_close".localized)
    }

    enum Layout {
        static let actionLineHeight: CGFloat = 17
    }
}

class HowToScanViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var descriptionText: ParagraphView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var hintView: HintView!
    @IBOutlet var actionView: ListItemView!
    @IBOutlet var toolbarView: CustomToolbarView!

    // MARK: - Properties

    private(set) var viewModel: HowToScanViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: HowToScanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
        configureHeadline()
        configureHintView()
        configureDescriptionText()
        configureToolbarView()
        configureActionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.sceneOpeningAnnouncement)
        UIAccessibility.post(notification: .layoutChanged, argument: headline.textLabel)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.sceneClosingAnnouncement)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureImageView()
    }

    // MARK: - Private

    private func configureImageView() {
        imageView.image = viewModel.image
        imageView.isHidden = UIScreen.isLandscape
        imageView.isAccessibilityElement = false
        imageView.pinHeightToScaleAspectFit()
    }

    private func configureHeadline() {
        headline.attributedTitleText = viewModel.title.styledAs(.header_2)
        headline.textLabel.accessibilityTraits = .header
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.actionButton.enableAccessibility(label: Constants.Accessibility.close.label, traits: .button)
        headline.layoutMargins.bottom = .space_24
    }

    private func configureHintView() {
        hintView.titleLabel.attributedText = "certificate_add_popup_note_title".localized.styledAs(.header_3)
        hintView.bodyLabel.attributedText = "certificate_add_popup_note_message".localized.styledAs(.body)
        hintView.isHidden = !viewModel.showPasscodeHint
    }

    private func configureActionView() {
        actionView.textLabel.attributedText = viewModel.actionTitle.styledAs(.header_3).lineHeight(Constants.Layout.actionLineHeight)
        actionView.action = { [weak self] in
            self?.viewModel.showMoreInformation()
        }
        actionView.tintColor = .brandAccent
    }

    private func configureDescriptionText() {
        descriptionText.updateView(body: viewModel.info.styledAs(.body))
        descriptionText.layoutMargins.top = .space_24
        descriptionText.layoutMargins.bottom = .space_24
        descriptionText.bottomBorder.isHidden = true
    }

    private func configureToolbarView() {
        toolbarView.state = .confirm(viewModel.startButtonTitle)
        toolbarView.layoutMargins.top = .space_24
        toolbarView.delegate = self
        toolbarView.disableLeftButton()
        toolbarView.disableRightButton()
        toolbarView.setWhiteGradient()
    }
}

// MARK: - CustomToolbarViewDelegate

extension HowToScanViewController: CustomToolbarViewDelegate {
    func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
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

extension HowToScanViewController: ModalInteractiveDismissibleProtocol {
    func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
