//
//  VaccinationView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

@IBDesignable
public class VaccinationView: XibView {
    @IBOutlet public var stackView: UIStackView!
    @IBOutlet var immunizationHeadline: PlainLabel!
    @IBOutlet var dateView: ParagraphView!
    @IBOutlet var vaccineView: ParagraphView!
    @IBOutlet var manufacturerView: ParagraphView!
    @IBOutlet var vaccineCodeView: ParagraphView!
    @IBOutlet var locationView: ParagraphView!
    @IBOutlet var issuerView: ParagraphView!
    @IBOutlet var countryView: ParagraphView!
    @IBOutlet var uvciView: ParagraphView!

    public var viewModel: VaccinationViewModel?

    public init(viewModel: VaccinationViewModel) {
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

    public override func initView() {
        super.initView()
        setupView()
    }
    
    internal func setupView() {
        layoutMargins = .init(top: 0, left: 0, bottom: 12, right: 0)
        stackView.spacing = .zero

        immunizationHeadline.attributedText = viewModel?.headline.toAttributedString(.h4)
        immunizationHeadline.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        immunizationHeadline.text = viewModel?.headline
        stackView.setCustomSpacing(12, after: immunizationHeadline)

        let itemsMargins = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)

        dateView.titleText = "vaccination_detail_date".localized
        dateView.bodyText = viewModel?.date
        dateView.isHidden = viewModel?.date.isEmpty ?? true
        dateView.contentView?.layoutMargins = itemsMargins
        dateView.showBottomBorder()

        vaccineView.titleText = "vaccination_detail_vaccine".localized
        vaccineView.bodyText = viewModel?.vaccine
        vaccineView.isHidden = viewModel?.vaccine.isEmpty ?? true
        vaccineView.contentView?.layoutMargins = itemsMargins
        vaccineView.showBottomBorder()

        manufacturerView.titleText = "vaccination_detail_manufacturer".localized
        manufacturerView.bodyText = viewModel?.manufacturer
        manufacturerView.isHidden = viewModel?.manufacturer.isEmpty ?? true
        manufacturerView.contentView?.layoutMargins = itemsMargins
        manufacturerView.showBottomBorder()

        vaccineCodeView.titleText = "vaccination_detail_vaccine_code".localized
        vaccineCodeView.bodyText = viewModel?.vaccineCode
        vaccineCodeView.isHidden = viewModel?.vaccineCode.isEmpty ?? true
        vaccineCodeView.contentView?.layoutMargins = itemsMargins
        vaccineCodeView.showBottomBorder()

        locationView.titleText = "vaccination_detail_location".localized
        locationView.bodyText = viewModel?.location
        locationView.isHidden = viewModel?.location.isEmpty ?? true
        locationView.contentView?.layoutMargins = itemsMargins
        locationView.showBottomBorder()

        issuerView.titleText = "vaccination_detail_issuer".localized
        issuerView.bodyText = viewModel?.issuer
        issuerView.isHidden = viewModel?.issuer.isEmpty ?? true
        issuerView.contentView?.layoutMargins = itemsMargins
        issuerView.showBottomBorder()

        countryView.titleText = "vaccination_detail_country".localized
        countryView.bodyText = viewModel?.country
        countryView.isHidden = viewModel?.country.isEmpty ?? true
        countryView.contentView?.layoutMargins = itemsMargins
        countryView.showBottomBorder()
        
        uvciView.titleText = "vaccination_detail_uvci".localized
        uvciView.bodyText = viewModel?.uvci
        uvciView.contentView?.layoutMargins = itemsMargins
        uvciView.isHidden = viewModel?.uvci.isEmpty ?? true
    }
}
