//
//  VaccinationView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

@IBDesignable
class VaccinationView: XibView {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var immunizationHeadline: InfoHeaderView!
    @IBOutlet var dateView: ParagraphView!
    @IBOutlet var vaccineView: ParagraphView!
    @IBOutlet var manufacturerView: ParagraphView!
    @IBOutlet var issuerView: ParagraphView!
    @IBOutlet var countryView: ParagraphView!
    @IBOutlet var uvciView: ParagraphView!
    @IBOutlet var qrButtonStackView: UIStackView!
    @IBOutlet var showQrCodeButton: MainButton!

    var viewModel: VaccinationViewModel?

    init(viewModel: VaccinationViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        setupView()
    }

    required init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override func initView() {
        super.initView()
        setupView()
    }

    func setupView() {
        layoutMargins = .zero
        stackView.spacing = .zero

        immunizationHeadline.attributedTitleText = viewModel?.headline.styledAs(.header_2)
        immunizationHeadline.image = .delete
        immunizationHeadline.action = { [weak self] in
            self?.viewModel?.delete()
        }
        immunizationHeadline.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
        stackView.setCustomSpacing(.space_12, after: immunizationHeadline)

        let itemsMargins = UIEdgeInsets(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)

        dateView.attributedTitleText = "vaccination_certificate_detail_view_data_date".localized.styledAs(.header_3)
        dateView.attributedBodyText = viewModel?.date.styledAs(.body)
        dateView.isHidden = viewModel?.date.isEmpty ?? true
        dateView.contentView?.layoutMargins = itemsMargins
        dateView.showBottomBorder()

        vaccineView.attributedTitleText = "vaccination_certificate_detail_view_data_vaccine".localized.styledAs(.header_3)
        vaccineView.attributedBodyText = viewModel?.fullVaccineProduct.styledAs(.body)
        vaccineView.isHidden = viewModel?.vaccine.isEmpty ?? true
        vaccineView.contentView?.layoutMargins = itemsMargins
        vaccineView.showBottomBorder()

        manufacturerView.attributedTitleText = "vaccination_certificate_detail_view_data_producer".localized.styledAs(.header_3)
        manufacturerView.attributedBodyText = viewModel?.manufacturer.styledAs(.body)
        manufacturerView.isHidden = viewModel?.manufacturer.isEmpty ?? true
        manufacturerView.contentView?.layoutMargins = itemsMargins
        manufacturerView.showBottomBorder()

        issuerView.attributedTitleText = "vaccination_certificate_detail_view_data_exhibitor".localized.styledAs(.header_3)
        issuerView.attributedBodyText = viewModel?.issuer.styledAs(.body)
        issuerView.isHidden = viewModel?.issuer.isEmpty ?? true
        issuerView.contentView?.layoutMargins = itemsMargins
        issuerView.showBottomBorder()

        countryView.attributedTitleText = "vaccination_certificate_detail_view_data_country".localized.styledAs(.header_3)
        countryView.attributedBodyText = viewModel?.country.styledAs(.body)
        countryView.isHidden = viewModel?.country.isEmpty ?? true
        countryView.contentView?.layoutMargins = itemsMargins
        countryView.showBottomBorder()

        uvciView.attributedTitleText = "vaccination_certificate_detail_view_data_identification_number".localized.styledAs(.header_3)
        uvciView.attributedBodyText = viewModel?.uvci.styledAs(.body)
        uvciView.contentView?.layoutMargins = itemsMargins
        uvciView.isHidden = viewModel?.uvci.isEmpty ?? true
        stackView.setCustomSpacing(.space_24, after: uvciView)

        qrButtonStackView.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        showQrCodeButton.title = "vaccination_certificate_detail_view_qrcode_action_button_title".localized
        showQrCodeButton.style = .secondary
        showQrCodeButton.icon = .scan
        showQrCodeButton.action = {
            self.viewModel?.showCertificate()
        }
    }
}
