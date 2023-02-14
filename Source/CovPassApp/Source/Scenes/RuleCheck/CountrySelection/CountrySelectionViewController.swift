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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.announce)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.closingAnnounce)
    }

    // MARK: - Private

    private func configureHeadline() {
        headline.attributedTitleText = "certificate_check_validity_selection_country_title".localized.styledAs(.header_2)
        headline.textLabel.accessibilityTraits = .header
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.layoutMargins.bottom = .space_24
        headline.actionButton.enableAccessibility(label: viewModel.close)
    }

    private func configureText() {
        info.linkFont = .scaledBoldBody
        info.attributedText = "certificate_check_validity_selection_country_note".localized.styledAs(.body)
        info.enableAccessibility(label: "certificate_check_validity_selection_country_note".localized)
        info.layoutMargins = .init(top: .space_8, left: .space_8, bottom: .space_8, right: .space_8)
        info.backgroundColor = .backgroundSecondary50
        info.layer.borderWidth = Constants.Layout.borderWith
        info.layer.borderColor = UIColor.backgroundSecondary60.cgColor
        info.layer.cornerRadius = Constants.Layout.cornerRadius
        info.applyRightImage(image: .externalLink)

        stackView.arrangedSubviews.forEach { subview in
            guard let item = subview as? CountryItemView else { return }
            item.removeFromSuperview()
            stackView.removeArrangedSubview(item)
        }
        viewModel.countries.forEach { country in
            // If there's no localization don't show the country
            guard country.code.localized != country.code else {
                return
            }
            let countryView = CountryItemView()
            countryView.leftIcon.image = UIImage(named: country.code.uppercased(), in: Bundle.uiBundle, compatibleWith: nil) ?? UIImage(named: "Oval", in: Bundle.uiBundle, compatibleWith: nil)
            countryView.textLabel.attributedText = country.code.localized.styledAs(.header_3)

            if viewModel.selectedCountry == country.code {
                countryView.rightIcon.image = .checkboxChecked
                countryView.enableAccessibility(label: String(format: viewModel.countrySelected, country.code.localized), traits: .button)
            } else {
                countryView.rightIcon.image = .checkboxUnchecked
                countryView.enableAccessibility(label: String(format: viewModel.countryUnselected, country.code.localized), traits: .button)
            }

            countryView.action = {
                self.viewModel.selectedCountry = country.code
                self.configureText()
            }
            stackView.addArrangedSubview(countryView)
        }

        toolbarView.state = .confirm(viewModel.select)
        toolbarView.delegate = self
        toolbarView.disableLeftButton()
        toolbarView.disableRightButton()
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
