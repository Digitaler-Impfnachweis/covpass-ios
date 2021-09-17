//
//  CountrySelectionViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

private enum Constants {
    enum Layout {
        static let cornerRadius: CGFloat = 12.0
        static let borderWith: CGFloat = 1.0
    }
    enum Accessibility {
        static let select = VoiceOverOptions.Settings(label: "certificate_check_validity_selection_country_action_button".localized)
        static let close = VoiceOverOptions.Settings(label: "accessibility_popup_label_close".localized)
        static let countrySelected = VoiceOverOptions.Settings(label: "accessibility_certificate_check_validity_selection_country_selected".localized)
        static let countryUnselected = VoiceOverOptions.Settings(label: "accessibility_certificate_check_validity_selection_country_unselected".localized)        
    }
}

class CountrySelectionViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var info: LinkLabel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var toolbarView: CustomToolbarView!

    // MARK: - Properties

    private(set) var viewModel: CountrySelectionViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: CountrySelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeadline()
        configureText()
    }

    // MARK: - Private

    private func configureHeadline() {
        headline.attributedTitleText = "certificate_check_validity_selection_country_title".localized.styledAs(.header_2)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.layoutMargins.bottom = .space_24
        headline.actionButton.enableAccessibility(label: Constants.Accessibility.close.label)
    }

    private func configureText() {
        info.attributedText = "certificate_check_validity_selection_country_note".localized.styledAs(.body)
        info.layoutMargins = .init(top: .space_8, left: .space_8, bottom: .space_8, right: .space_8)
        info.backgroundColor = .backgroundSecondary20
        info.layer.borderWidth = Constants.Layout.borderWith
        info.layer.borderColor = UIColor.onBackground20.cgColor
        info.layer.cornerRadius = Constants.Layout.cornerRadius

        stackView.arrangedSubviews.forEach { subview in
            guard let item = subview as? CountryItemView else { return }
            item.removeFromSuperview()
            stackView.removeArrangedSubview(item)
        }
        viewModel.countries.forEach { country in
            let countryView = CountryItemView()
            countryView.leftIcon.image = UIImage(named: country.uppercased(), in: Bundle.uiBundle, compatibleWith: nil)
            countryView.textLabel.attributedText = country.localized.styledAs(.header_3)

            // We can use forced unwrapping because it's set via Constants
            if viewModel.country == country {
                countryView.rightIcon.image = .checkboxChecked
                countryView.enableAccessibility(label: String(format: Constants.Accessibility.countrySelected.label!, country.localized), traits: .button)
            } else {
                countryView.rightIcon.image = .checkboxUnchecked
                countryView.enableAccessibility(label: String(format: Constants.Accessibility.countryUnselected.label!, country.localized), traits: .button)
            }

            countryView.action = {
                self.viewModel.country = country
                self.configureText()
            }
            stackView.addArrangedSubview(countryView)
        }

        // We can use forced unwrapping here because it's set via Constants
        toolbarView.state = .confirm(Constants.Accessibility.close.label!)
        toolbarView.delegate = self
    }
}

// MARK: - CustomToolbarViewDelegate

extension CountrySelectionViewController: CustomToolbarViewDelegate {
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
