//
//  RuleCheckViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit
import CovPassCommon

class RuleCheckViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var subtitle: PlainLabel!
    @IBOutlet var countrySelection: InputView!
    @IBOutlet var dateSelection: InputView!
    @IBOutlet var info: LinkLabel!
    @IBOutlet var loadingIndicagtor: DotPulseActivityIndicator!
    @IBOutlet var scrollView: UIScrollView!

    // MARK: - Properties

    private(set) var viewModel: RuleCheckViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: RuleCheckViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
        self.viewModel.delegate = self
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureText()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateRules()
    }

    // MARK: - Private

    private func configureText() {
        headline.attributedTitleText = "certificate_check_validity_title".localized.styledAs(.header_2)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.layoutMargins.bottom = .space_24

        subtitle.attributedText = "certificate_check_validity_message".localized.styledAs(.body)
        subtitle.layoutMargins = .init(top: .zero, left: .space_24, bottom: .space_24, right: .space_24)

        countrySelection.titleLabel.attributedText = "certificate_check_validity_selection_country".localized.styledAs(.body)
        countrySelection.valueLabel.attributedText = viewModel.country.localized.styledAs(.body)
        countrySelection.iconView.image = UIImage.map
        countrySelection.onClickAction = { [weak self] in
            self?.viewModel.showCountrySelection()
        }

        dateSelection.titleLabel.attributedText = "certificate_check_validity_selection_date".localized.styledAs(.body)
        dateSelection.valueLabel.attributedText = DateUtils.displayDateTimeFormatter.string(from: viewModel.date).styledAs(.body)
        dateSelection.iconView.image = UIImage.calendar.withRenderingMode(.alwaysTemplate)
        dateSelection.layoutMargins.bottom = .space_40
        dateSelection.onClickAction = { [weak self] in
            self?.viewModel.showDateSelection()
        }

        info.attributedText = "certificate_check_validity_note".localized.styledAs(.body)
        info.layoutMargins = .init(top: .space_8, left: .space_8, bottom: .space_8, right: .space_8)
        info.backgroundColor = .backgroundSecondary20
        info.layer.borderWidth = 1.0
        info.layer.borderColor = UIColor.onBackground20.cgColor
        info.layer.cornerRadius = 12.0

        if viewModel.isLoading {
            loadingIndicagtor.isHidden = false
            loadingIndicagtor.startAnimating()
            scrollView.isHidden = true
        } else {
            loadingIndicagtor.stopAnimating()
            loadingIndicagtor.isHidden = true
            scrollView.isHidden = false
        }
    }
}

// MARK: - ViewModelDelegate

extension RuleCheckViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        configureText()
    }

    func viewModelUpdateDidFailWithError(_ error: Error) {}
}
