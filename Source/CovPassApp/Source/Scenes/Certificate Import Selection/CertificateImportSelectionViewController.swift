//
//  CertificateImportSelectionViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

final class CertificateImportSelectionViewController: UIViewController {
    @IBOutlet weak var infoHeaderView: InfoHeaderView!
    @IBOutlet weak var selectionTitleLabel: UILabel!
    @IBOutlet weak var selectionTitleView: UIView!
    @IBOutlet weak var selectionTitleCheckboxImage: UIImageView!
    @IBOutlet weak var itemSelectionStackView: UIStackView!
    @IBOutlet weak var hintView: HintView!
    @IBOutlet weak var importButton: MainButton!

    private let viewModel: CertificateImportSelectionViewModelProtocol
    
    init(viewModel: CertificateImportSelectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInfoHeaderView()
        configureSelectionTitle()
        configureItemSelectionStackView()
        configureHintView()
        configureButton()
    }

    private func configureInfoHeaderView() {
        infoHeaderView.image = .close
        infoHeaderView.attributedTitleText = viewModel.title.styledAs(.header_20)
        infoHeaderView.action = viewModel.cancel
    }

    private func configureSelectionTitle() {
        switch viewModel.itemSelectionState {
        case .none:
            selectionTitleCheckboxImage.image = .checkboxUnchecked
        case .all:
            selectionTitleCheckboxImage.image = .checkboxChecked
        case .some:
            selectionTitleCheckboxImage.image = .checkboxPartial
        }

        selectionTitleLabel.attributedText = viewModel.selectionTitle
            .styledAs(.header_3)
            .colored(.onBackground110)
        selectionTitleView.isHidden = viewModel.hideSelection
    }

    private func configureItemSelectionStackView() {
        itemSelectionStackView.removeAllArrangedSubviews()
        itemSelectionStackView.isHidden = viewModel.hideSelection
        
        for index in 0..<viewModel.items.count {
            let item = viewModel.items[index]
            let view = CertificateImportSelectionItemView()

            view.titleLabel.attributedText = item.title
                .styledAs(.header_3)
                .colored(.onBackground110)
            view.subtitleLabel.attributedText = item.subtitle
                .styledAs(.body)
                .colored(.onBackground110)
            view.checkmarkButton.addTarget(
                self,
                action: #selector(certificateSelected(_:)),
                for: .primaryActionTriggered
            )
            view.checkmarkButton.isSelected = item.selected
            view.checkmarkButton.tag = index

            for line in item.additionalLines {
                let label = UILabel()
                label.attributedText = line
                    .styledAs(.body)
                    .colored(.onBackground80)
                view.stackView.addArrangedSubview(label)
            }

            itemSelectionStackView.addArrangedSubview(view)
        }
    }

    @IBAction private func certificateSelected(_ button: UIButton) {
        let item = viewModel.items[button.tag]
        item.selected.toggle()
        button.isSelected = item.selected
        refreshViews()
    }

    private func refreshViews() {
        configureSelectionTitle()
        configureItemSelectionStackView()
        configureButton()
    }

    private func configureHintView() {
        let attributedBulletStrings = viewModel.hintTextBulletPoints
            .map { $0.styledAs(.body).colored(.onBackground110) }
        hintView.bodyLabel.attributedText = .toBullets(attributedBulletStrings)
        hintView.titleLabel.attributedText = viewModel.hintTitle
            .styledAs(.header_3)
            .colored(.onBackground110)
        hintView.containerView.backgroundColor = .brandAccent30
        hintView.containerView.layer.borderColor = UIColor.brandAccent20.cgColor
        hintView.iconView.image = .infoSignal
    }

    private func configureButton() {
        importButton.isEnabled = viewModel.enableButton
        importButton.title = viewModel.buttonTitle
        importButton.action = viewModel.confirm
    }
}
