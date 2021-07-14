//
//  CountrySelectionViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

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
        configureText()
    }

    // MARK: - Private

    private func configureText() {
        headline.attributedTitleText = "certificate_check_validity_selection_country_title".localized.styledAs(.header_2)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.layoutMargins.bottom = .space_24

        info.attributedText = "certificate_check_validity_selection_country_note".localized.styledAs(.body)
        info.layoutMargins = .init(top: .space_8, left: .space_8, bottom: .space_8, right: .space_8)
        info.backgroundColor = .backgroundSecondary20
        info.layer.borderWidth = 1.0
        info.layer.borderColor = UIColor.onBackground20.cgColor
        info.layer.cornerRadius = 12.0

        stackView.arrangedSubviews.forEach { subview in
            guard let item = subview as? CountryItemView else { return }
            item.removeFromSuperview()
            stackView.removeArrangedSubview(item)
        }
        viewModel.countries.forEach { country in
            let countryView = CountryItemView()
            countryView.leftIcon.image = UIImage(named: country.uppercased(), in: Bundle.uiBundle, compatibleWith: nil)
            countryView.textLabel.attributedText = country.localized.styledAs(.header_3)
            countryView.rightIcon.image = viewModel.country == country ? .checkboxChecked : .checkboxUnchecked
            countryView.action = {
                self.viewModel.country = country
                self.configureText()
            }
            stackView.addArrangedSubview(countryView)
        }

        toolbarView.state = .confirm("certificate_check_validity_selection_country_action_button".localized)
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
