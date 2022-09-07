//
//  NewRegulationsAnnouncementViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class NewRegulationsAnnouncementViewController: UIViewController {

    @IBOutlet var infoHeaderView: InfoHeaderView!
    @IBOutlet var illustrationImageView: UIImageView!
    @IBOutlet var copyText1Label: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var copyText2Label: UILabel!
    @IBOutlet var button: MainButton!
    private let viewModel: NewRegulationsAnnouncementViewModelProtocol

    init(viewModel: NewRegulationsAnnouncementViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInfoHeaderView()
        setupIllustration()
        setupLabels()
        setupButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupInfoHeaderView() {
        infoHeaderView.attributedTitleText = viewModel.header
            .styledAs(.header_2)
        infoHeaderView.action = viewModel.close
        infoHeaderView.image = .close
        infoHeaderView.layoutMargins.bottom = .space_12
    }

    private func setupIllustration() {
        illustrationImageView.image = viewModel.illustration
    }

    private func setupLabels() {
        let textColor = UIColor.onBackground110
        copyText1Label.attributedText = viewModel.copyText1
            .styledAs(.body)
            .colored(textColor)
        copyText2Label.attributedText = viewModel.copyText2
            .styledAs(.body)
            .colored(textColor)
        subtitleLabel.attributedText = viewModel.subtitle
            .styledAs(.header_3)
            .colored(textColor)
    }

    private func setupButton() {
        button.title = viewModel.buttonTitle
        button.action = viewModel.close
    }
}

extension NewRegulationsAnnouncementViewController: ModalInteractiveDismissibleProtocol {
    func modalViewControllerDidDismiss() {
        viewModel.close()
    }
}
