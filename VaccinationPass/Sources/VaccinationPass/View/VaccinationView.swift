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

        immunizationHeadline.attributedText = viewModel?.headline.styledAs(.header_2)
        immunizationHeadline.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
        stackView.setCustomSpacing(.space_12, after: immunizationHeadline)

        let itemsMargins = UIEdgeInsets(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)

        dateView.attributedTitleText = "vaccination_detail_date".localized.styledAs(.header_3)
        dateView.attributedBodyText = viewModel?.date.styledAs(.body)
        dateView.isHidden = viewModel?.date.isEmpty ?? true
        dateView.contentView?.layoutMargins = itemsMargins
        dateView.showBottomBorder()

        vaccineView.attributedTitleText = "vaccination_detail_vaccine".localized.styledAs(.header_3)
        vaccineView.attributedBodyText = viewModel?.vaccine.styledAs(.body)
        vaccineView.isHidden = viewModel?.vaccine.isEmpty ?? true
        vaccineView.contentView?.layoutMargins = itemsMargins
        vaccineView.showBottomBorder()

        manufacturerView.attributedTitleText = "vaccination_detail_manufacturer".localized.styledAs(.header_3)
        manufacturerView.attributedBodyText = viewModel?.vaccine.styledAs(.body)
        manufacturerView.isHidden = viewModel?.manufacturer.isEmpty ?? true
        manufacturerView.contentView?.layoutMargins = itemsMargins
        manufacturerView.showBottomBorder()

        vaccineCodeView.attributedTitleText = "vaccination_detail_vaccine_code".localized.styledAs(.header_3)
        vaccineCodeView.attributedBodyText = viewModel?.vaccineCode.styledAs(.body)
        vaccineCodeView.isHidden = viewModel?.vaccineCode.isEmpty ?? true
        vaccineCodeView.contentView?.layoutMargins = itemsMargins
        vaccineCodeView.showBottomBorder()

        issuerView.attributedTitleText = "vaccination_detail_issuer".localized.styledAs(.header_3)
        issuerView.attributedBodyText = viewModel?.issuer.styledAs(.body)
        issuerView.isHidden = viewModel?.issuer.isEmpty ?? true
        issuerView.contentView?.layoutMargins = itemsMargins
        issuerView.showBottomBorder()

        countryView.attributedTitleText = "vaccination_detail_country".localized.styledAs(.header_3)
        countryView.attributedBodyText = viewModel?.country.styledAs(.body)
        countryView.isHidden = viewModel?.country.isEmpty ?? true
        countryView.contentView?.layoutMargins = itemsMargins
        countryView.showBottomBorder()

        uvciView.attributedTitleText = "vaccination_detail_uvci".localized.styledAs(.header_3)
        uvciView.attributedBodyText = viewModel?.uvci.styledAs(.body)
        uvciView.contentView?.layoutMargins = itemsMargins
        uvciView.isHidden = viewModel?.uvci.isEmpty ?? true
    }
}
