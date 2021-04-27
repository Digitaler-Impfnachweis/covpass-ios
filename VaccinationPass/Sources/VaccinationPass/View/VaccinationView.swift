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
    @IBOutlet var immunizationHeadline: Headline!
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
        immunizationHeadline.text = viewModel?.headline
        dateView.titleText = "vaccination_detail_date".localized
        dateView.bodyText = viewModel?.date
        dateView.isHidden = viewModel?.date.isEmpty ?? true
        dateView.showBottomBorder()
        vaccineView.titleText = "vaccination_detail_vaccine".localized
        vaccineView.bodyText = viewModel?.vaccine
        vaccineView.isHidden = viewModel?.vaccine.isEmpty ?? true
        vaccineView.showBottomBorder()
        manufacturerView.titleText = "vaccination_detail_manufacturer".localized
        manufacturerView.bodyText = viewModel?.manufacturer
        manufacturerView.isHidden = viewModel?.manufacturer.isEmpty ?? true
        manufacturerView.showBottomBorder()
        vaccineCodeView.titleText = "vaccination_detail_vaccine_code".localized
        vaccineCodeView.bodyText = viewModel?.vaccineCode
        vaccineCodeView.isHidden = viewModel?.vaccineCode.isEmpty ?? true
        vaccineCodeView.showBottomBorder()
        locationView.titleText = "vaccination_detail_location".localized
        locationView.bodyText = viewModel?.location
        locationView.isHidden = viewModel?.location.isEmpty ?? true
        locationView.showBottomBorder()
        issuerView.titleText = "vaccination_detail_issuer".localized
        issuerView.bodyText = viewModel?.issuer
        issuerView.isHidden = viewModel?.issuer.isEmpty ?? true
        issuerView.showBottomBorder()
        countryView.titleText = "vaccination_detail_country".localized
        countryView.bodyText = viewModel?.country
        countryView.isHidden = viewModel?.country.isEmpty ?? true
        countryView.showBottomBorder()
        uvciView.titleText = "vaccination_detail_uvci".localized
        uvciView.bodyText = viewModel?.uvci
        uvciView.isHidden = viewModel?.uvci.isEmpty ?? true
    }
}
