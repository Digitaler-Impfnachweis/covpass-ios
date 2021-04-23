//
//  VaccinationDetailViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import VaccinationUI
import UIKit
import VaccinationCommon

public class VaccinationDetailViewController: UIViewController {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var nameHeadline: Headline!
    @IBOutlet var immunizationView: ParagraphIconView!
    @IBOutlet var immunizationButton: PrimaryButtonContainer!
    @IBOutlet var personalDataHeadline: Headline!
    @IBOutlet var nameView: ParagraphView!
    @IBOutlet var birtdateView: ParagraphView!
    
    public var viewModel: VaccinationDetailViewModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = UIConstants.BrandColor.backgroundPrimary

        nameHeadline.font = UIFont.ibmPlexSansSemiBold(with: 32)
        nameHeadline.text = viewModel.name
        
        immunizationView.icon.image = viewModel.immunizationIcon
        immunizationView.titleText = viewModel.immunizationTitle
        immunizationView.bodyText = viewModel.immunizationBody
        
        immunizationButton.title = viewModel.immunizationButton
        immunizationButton.backgroundColor = UIColor.white
        immunizationButton.shadowColor = UIColor.white

        personalDataHeadline.text = "vaccination_detail_personal_information".localized
        nameView.titleText = "vaccination_detail_name".localized
        nameView.bodyText = viewModel.name
        nameView.showBottomBorder()
        birtdateView.titleText = "vaccination_detail_birthdate".localized
        birtdateView.bodyText = viewModel.birthDate
        
        viewModel.vaccinations.forEach({ stackView.addArrangedSubview(VaccinationView(viewModel: $0)) })
    }
}

extension VaccinationDetailViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        VaccinationPassConstants.Storyboard.Pass
    }
}
