//
//  VaccinationView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

@IBDesignable
public class VaccinationView: MarginableXibView {
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

    public override var margins: [Margin] {
        return [
//            RelatedViewMargin(constant: 40, relatedViewType: PrimaryButtonContainer.self),
//            RelatedViewMargin(constant: 24, relatedViewType: ParagraphView.self),
//            RelatedViewMargin(constant: 12, relatedViewType: Headline.self),
//            RelatedViewMargin(constant: 12, relatedViewType: Spacer.self),
//            PositionMargin(constant: topMargin, position: 24, type: .top),
        ]
    }

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
//        dateView.addBottomBorder()
        vaccineView.titleText = "vaccination_detail_vaccine".localized
        vaccineView.bodyText = viewModel?.vaccine
        vaccineView.isHidden = viewModel?.vaccine.isEmpty ?? true
////        vaccineView.addBottomBorder()
        manufacturerView.titleText = "vaccination_detail_manufacturer".localized
        manufacturerView.bodyText = viewModel?.manufacturer
        manufacturerView.isHidden = viewModel?.manufacturer.isEmpty ?? true
////        manufacturerView.addBottomBorder()
        vaccineCodeView.titleText = "vaccination_detail_vaccine_code".localized
        vaccineCodeView.bodyText = viewModel?.vaccineCode
        vaccineCodeView.isHidden = viewModel?.vaccineCode.isEmpty ?? true
////        numberView.addBottomBorder()
        locationView.titleText = "vaccination_detail_location".localized
        locationView.bodyText = viewModel?.location
        locationView.isHidden = viewModel?.location.isEmpty ?? true
////        locationView.addBottomBorder()
        issuerView.titleText = "vaccination_detail_issuer".localized
        issuerView.bodyText = viewModel?.issuer
        issuerView.isHidden = viewModel?.issuer.isEmpty ?? true
////        issuerView.addBottomBorder()
        countryView.titleText = "vaccination_detail_country".localized
        countryView.bodyText = viewModel?.country
        countryView.isHidden = viewModel?.country.isEmpty ?? true
////        countryView.addBottomBorder()
        uvciView.titleText = "vaccination_detail_uvci".localized
        uvciView.bodyText = viewModel?.uvci
        uvciView.isHidden = viewModel?.uvci.isEmpty ?? true
////        uvciView.addBottomBorder()
    }
}
