//
//  SecondScanViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class SecondScanViewController: UIViewController {
    @IBOutlet var headerView: InfoHeaderView!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var fistScanView: ImageTitleSubtitleView!
    @IBOutlet var secondScanView: ImageTitleSubtitleView!
    @IBOutlet var thirdScanView: ImageTitleSubtitleView!
    @IBOutlet var scanNextButton: MainButton!
    @IBOutlet var startoverButton: MainButton!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var hintView: HintView!

    private var viewModel: SecondScanViewModelProtocol

    init(viewModel: SecondScanViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder _: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        UIAccessibility.post(notification: .layoutChanged, argument: headerStackView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startCountdown()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopCountdown()
    }

    private func configureView() {
        headerView.attributedTitleText = viewModel.title.styledAs(.header_2)
        subtitleLabel.attributedText = viewModel.subtitle.styledAs(.body)
        headerView.image = .close
        headerView.action = viewModel.cancel
        thirdScanView.isHidden = viewModel.thirdScanViewIsHidden
        configureFirstScanView()
        configureSecondScanView()
        configureThirdScanView()
        configureHintView()
        configureButton()
        configureCounter()
        configureAccessibility()
    }

    private func configureFirstScanView() {
        let title = viewModel.firstScanTitle.styledAs(.header_2)
        let subtitle = viewModel.firstScanSubtitle.styledAs(.body)
        let image = viewModel.firstScanIcon
        fistScanView.update(title: title, subtitle: subtitle, leftImage: image)
    }

    private func configureSecondScanView() {
        let title = viewModel.secondScanTitle.styledAs(.header_2)
        let subtitle = viewModel.secondScanSubtitle.styledAs(.body)
        let image = viewModel.secondScanIcon
        secondScanView.update(title: title, subtitle: subtitle, leftImage: image)
    }

    private func configureThirdScanView() {
        let title = viewModel.thirdScanTitle.styledAs(.header_2)
        let subtitle = viewModel.thirdScanSubtitle.styledAs(.body)
        let image = viewModel.thirdScanIcon
        thirdScanView.update(title: title, subtitle: subtitle, leftImage: image)
    }

    private func configureHintView() {
        hintView.titleLabel.attributedText = viewModel.hintTitle.styledAs(.header_3)
        hintView.bodyLabel.attributedText = viewModel.hintSubtitle.styledAs(.body)
        hintView.style = .warning
    }

    private func configureButton() {
        startoverButton.title = viewModel.startOverButtonTitle
        startoverButton.action = viewModel.startOver
        startoverButton.style = .alternative
        scanNextButton.title = viewModel.scanNextButtonTitle
        scanNextButton.action = viewModel.scanNext
    }

    private func configureCounter() {
        let countdownTimerModel = viewModel.countdownTimerModel
        let counterInfo = NSMutableAttributedString(
            attributedString: countdownTimerModel.counterInfo.styledAs(.body)
        )
        counterLabel.isHidden = countdownTimerModel.hideCountdown
        counterLabel.attributedText = counterInfo
        counterLabel.textAlignment = .center
    }

    private func configureAccessibility() {
        if #available(iOS 13.0, *) {
            subtitleLabel.accessibilityRespondsToUserInteraction = true
            fistScanView.accessibilityRespondsToUserInteraction = true
            secondScanView.accessibilityRespondsToUserInteraction = true
            thirdScanView.accessibilityRespondsToUserInteraction = true
            counterLabel.accessibilityRespondsToUserInteraction = true
        }
    }
}

extension SecondScanViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        configureView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}

// MARK: - ModalInteractiveDismissibleProtocol

extension SecondScanViewController: ModalInteractiveDismissibleProtocol {
    func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
