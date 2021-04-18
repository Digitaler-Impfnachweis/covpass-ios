//
//  VaccinationDetailViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import VaccinationUI
import UIKit

public class VaccinationDetailViewController: UIViewController {
    @IBOutlet var nameHeadline: Headline!
    @IBOutlet var immunizationView: ParagraphIconView!
    @IBOutlet var immunizationTicketButton: PrimaryButtonContainer!
    @IBOutlet var immunizationScanButton: SecondaryButtonContainer!
    @IBOutlet var personalDataHeadline: Headline!
    @IBOutlet var nameView: ParagraphView!
    @IBOutlet var birtdateView: ParagraphView!
    @IBOutlet var immunization1Headline: Headline!
    @IBOutlet var location1View: ParagraphView!
    @IBOutlet var vaccine1View: ParagraphView!
    @IBOutlet var number1View: ParagraphView!
    @IBOutlet var date1View: ParagraphView!
    
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
        immunizationView.titleText = viewModel.immunizationText
        immunizationView.bodyText = viewModel.immunizationBody
        
        immunizationTicketButton.title = viewModel.immunizationTicketButton
        immunizationTicketButton.backgroundColor = UIColor.white
        immunizationTicketButton.shadowColor = UIColor.white
        
        immunizationScanButton.title = "2. Impfung hinzufügen"
        immunizationScanButton.backgroundColor = UIColor.white
        immunizationScanButton.shadowColor = UIColor.white
        immunizationScanButton.isHidden = !viewModel.partialVaccination

        personalDataHeadline.text = "Persönliche Daten"
        nameView.titleText = "Name"
        nameView.bodyText = "Max Mustermann"
        nameView.addBottomBorder()
        birtdateView.titleText = "Geburtsdatum"
        birtdateView.bodyText = "18.04.1953"
        
        immunization1Headline.text = "Impfung 1 von 2"
        location1View.titleText = "Zentrales Impfzentrum, Musterstadt"
        location1View.bodyText = "03.02.2021"
        location1View.addBottomBorder()
        vaccine1View.titleText = "Impfstoff"
        vaccine1View.bodyText = "mRNA"
        vaccine1View.addBottomBorder()
        number1View.titleText = "Chargennummer"
        number1View.bodyText = "DA123456"
        number1View.addBottomBorder()
        date1View.titleText = "Datum der Impfung"
        date1View.bodyText = "03.02.2021"
    }
}

extension VaccinationDetailViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        VaccinationPassConstants.Storyboard.Pass
    }
}
