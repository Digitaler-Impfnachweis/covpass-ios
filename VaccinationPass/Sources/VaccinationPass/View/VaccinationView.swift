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
        layoutMargins = .zero
        stackView.spacing = .zero

        immunizationHeadline.attributedText = viewModel?.headline.toAttributedString(.h4)
        immunizationHeadline.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        stackView.setCustomSpacing(12, after: immunizationHeadline)

        let itemsMargins = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)

        dateView.titleAttributedText = "vaccination_detail_date".localized.toAttributedString(.h5)
        dateView.bodyAttributedText = viewModel?.date.toAttributedString(.body)
        dateView.isHidden = viewModel?.date.isEmpty ?? true
        dateView.contentView?.layoutMargins = itemsMargins
        dateView.showBottomBorder()

        vaccineView.titleAttributedText = "vaccination_detail_vaccine".localized.toAttributedString(.h5)
        vaccineView.bodyAttributedText = viewModel?.vaccine.toAttributedString(.body)
        vaccineView.isHidden = viewModel?.vaccine.isEmpty ?? true
        vaccineView.contentView?.layoutMargins = itemsMargins
        vaccineView.showBottomBorder()

        manufacturerView.titleAttributedText = "vaccination_detail_manufacturer".localized.toAttributedString(.h5)
        manufacturerView.bodyAttributedText = viewModel?.vaccine.toAttributedString(.body)
        manufacturerView.isHidden = viewModel?.manufacturer.isEmpty ?? true
        manufacturerView.contentView?.layoutMargins = itemsMargins
        manufacturerView.showBottomBorder()

        vaccineCodeView.titleAttributedText = "vaccination_detail_vaccine_code".localized.toAttributedString(.h5)
        vaccineCodeView.bodyAttributedText = viewModel?.vaccineCode.toAttributedString(.body)
        vaccineCodeView.isHidden = viewModel?.vaccineCode.isEmpty ?? true
        vaccineCodeView.contentView?.layoutMargins = itemsMargins
        vaccineCodeView.showBottomBorder()

        locationView.titleAttributedText = "vaccination_detail_location".localized.toAttributedString(.h5)
        locationView.bodyAttributedText = viewModel?.location.toAttributedString(.body)
        locationView.isHidden = viewModel?.location.isEmpty ?? true
        locationView.contentView?.layoutMargins = itemsMargins
        locationView.showBottomBorder()

        issuerView.titleAttributedText = "vaccination_detail_issuer".localized.toAttributedString(.h5)
        issuerView.bodyAttributedText = viewModel?.issuer.toAttributedString(.body)
        issuerView.isHidden = viewModel?.issuer.isEmpty ?? true
        issuerView.contentView?.layoutMargins = itemsMargins
        issuerView.showBottomBorder()

        countryView.titleAttributedText = "vaccination_detail_country".localized.toAttributedString(.h5)
        countryView.bodyAttributedText = viewModel?.country.toAttributedString(.body)
        countryView.isHidden = viewModel?.country.isEmpty ?? true
        countryView.contentView?.layoutMargins = itemsMargins
        countryView.showBottomBorder()

        uvciView.titleAttributedText = "vaccination_detail_uvci".localized.toAttributedString(.h5)
        uvciView.bodyAttributedText = viewModel?.uvci.toAttributedString(.body)
        uvciView.contentView?.layoutMargins = itemsMargins
        uvciView.isHidden = viewModel?.uvci.isEmpty ?? true
    }
}
