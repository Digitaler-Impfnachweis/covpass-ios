//
//  DateSelectionViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

private enum Constants {
    enum Accessibility {
        static let close = VoiceOverOptions.Settings(label: "accessibility_popup_label_close".localized)
    }
}

class DateSelectionViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var toolbarView: CustomToolbarView!

    // MARK: - Properties

    private(set) var viewModel: DateSelectionViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: DateSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
        self.viewModel.delegate = self
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureText()
    }

    // MARK: - Private

    private func configureText() {
        headline.attributedTitleText = "certificate_check_validity_selection_date_title".localized.styledAs(.header_2)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.actionButton.enableAccessibility(label: Constants.Accessibility.close.label)
        headline.layoutMargins.bottom = .space_24

        datePicker.date = viewModel.date
        datePicker.datePickerMode = viewModel.step == .One ? .date : .time
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)

        toolbarView.state = viewModel.step == .One ? .confirm("certificate_check_validity_selection_date_action_button".localized) : .confirm("certificate_check_validity_selection_time_action_button".localized)
        toolbarView.setUpLeftButton(leftButtonItem: viewModel.step == .One ? nil : .navigationArrow)
        toolbarView.delegate = self
    }

    @objc private func datePickerChanged(picker: UIDatePicker) {
        viewModel.date = picker.date
    }
}

// MARK: - ViewModelDelegate

extension DateSelectionViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        configureText()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}

// MARK: - CustomToolbarViewDelegate

extension DateSelectionViewController: CustomToolbarViewDelegate {
    func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            viewModel.back()
        case .textButton:
            viewModel.done()
        default:
            return
        }
    }
}
