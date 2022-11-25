//
//  CertificateImportSelectionViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

final class CertificateImportSelectionViewController: UIViewController {
    @IBOutlet var infoHeaderView: InfoHeaderView!
    @IBOutlet var selectionTitleLabel: UILabel!
    @IBOutlet var selectionTitleView: UIView!
    @IBOutlet var selectionTitleCheckboxButton: UIButton!
    @IBOutlet var itemSelectionStackView: UIStackView!
    @IBOutlet var hintView: HintView!
    @IBOutlet var importButton: MainButton!

    private var viewModel: CertificateImportSelectionViewModelProtocol

    init(viewModel: CertificateImportSelectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder _: NSCoder) {
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

    // MARK: - Actions

    @IBAction func toggleSelection() {
        viewModel.toggleSelection()
        refreshViews()
    }

    // MARK: - View configuration

    private func configureInfoHeaderView() {
        infoHeaderView.image = .close
        infoHeaderView.attributedTitleText = viewModel.title.styledAs(.header_2)
        infoHeaderView.action = viewModel.cancel
    }

    private func configureSelectionTitle() {
        switch viewModel.itemSelectionState {
        case .none:
            selectionTitleCheckboxButton.setImage(.checkboxUnchecked, for: .normal)
        case .all:
            selectionTitleCheckboxButton.setImage(.checkboxChecked, for: .normal)
        case .some:
            selectionTitleCheckboxButton.setImage(.checkboxPartial, for: .normal)
        }

        selectionTitleCheckboxButton.setTitle("", for: .normal)
        selectionTitleLabel.attributedText = viewModel.selectionTitle
            .styledAs(.header_3)
            .colored(.onBackground110)
        selectionTitleView.isHidden = viewModel.hideSelection
    }

    private func configureItemSelectionStackView() {
        itemSelectionStackView.removeAllArrangedSubviews()
        itemSelectionStackView.isHidden = viewModel.hideSelection

        for index in 0 ..< viewModel.items.count {
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
        hintView.containerView.backgroundColor = .brandAccent20
        hintView.containerView.layer.borderColor = UIColor.brandAccent40.cgColor
        hintView.iconView.image = .infoSignal
    }

    private func configureButton() {
        importButton.isEnabled = viewModel.enableButton
        importButton.title = viewModel.buttonTitle
        importButton.action = viewModel.confirm
        viewModel.isImportingCertificates ? importButton.startAnimating() : importButton.stopAnimating()
    }
}

extension CertificateImportSelectionViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        configureButton()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}
