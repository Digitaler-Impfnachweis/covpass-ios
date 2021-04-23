//
//  VaccinationDetailViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import VaccinationUI
import UIKit
import VaccinationCommon

let cert = """
{ \
    "name": "Mustermann Erika", \
    "birthDate": "19640812", \
    "identifier": "C01X00T47", \
    "sex": "female", \
    "vaccination": [{ \
        "targetDisease": "U07.1!", \
        "vaccineCode": "1119349007", \
        "product": "COMIRNATY", \
        "manufacturer": "BioNTech Manufacturing GmbH11", \
        "series": "1/1", \
        "lotNumber": "T654X4", \
        "occurence": "20210202", \
        "location": "84503", \
        "performer": "999999900", \
        "country": "DE", \
        "nextDate": "20210402" \
    }], \
    "issuer": "Landratsamt Altötting", \
    "id": "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", \
    "validFrom": "20200202", \
    "validUntil": "20230202", \
    "version": "1.0.0", \
    "secret": "ZFKIYIBK39A3#S" \
}
"""

let cert2 = """
{ \
    "name": "Mustermann Erika", \
    "birthDate": "19640812", \
    "identifier": "C01X00T47", \
    "sex": "female", \
    "vaccination": [{ \
        "targetDisease": "U07.1!", \
        "vaccineCode": "1119349007", \
        "product": "COMIRNATY", \
        "manufacturer": "BioNTech Manufacturing GmbH11", \
        "series": "2/2", \
        "lotNumber": "T654X4", \
        "occurence": "20210202", \
        "location": "84503", \
        "performer": "999999900", \
        "country": "DE", \
        "nextDate": "20210402" \
    }], \
    "issuer": "Landratsamt Altötting", \
    "id": "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", \
    "validFrom": "20200202", \
    "validUntil": "20230202", \
    "version": "1.0.0", \
    "secret": "ZFKIYIBK39A3#S" \
}
"""

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
        let sut = try! JSONDecoder().decode(VaccinationCertificate.self, from: cert.data(using: .utf8)!)
        let cert = ExtendedVaccinationCertificate(vaccinationCertificate: sut, vaccinationQRCodeData: "", validationQRCodeData: nil)
        let sut2 = try! JSONDecoder().decode(VaccinationCertificate.self, from: cert2.data(using: .utf8)!)
        let cert2 = ExtendedVaccinationCertificate(vaccinationCertificate: sut2, vaccinationQRCodeData: "", validationQRCodeData: nil)
        viewModel = VaccinationDetailViewModel(certificates: [cert])
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
        nameView.addBottomBorder()
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
