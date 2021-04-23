//
//  VaccinationDetailViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI
import VaccinationCommon

public struct VaccinationDetailViewModel {

    private var certificates: [ExtendedVaccinationCertificate]

    public init(certificates: [ExtendedVaccinationCertificate]) {
        self.certificates = certificates
    }

    private var partialVaccination: Bool {
        return certificates.map({ $0.vaccinationCertificate.partialVaccination }).first(where: { !$0 }) ?? true
    }

    public var name: String {
        return certificates.first?.vaccinationCertificate.name ?? ""
    }

    public var birthDate: String {
        guard let date = certificates.first?.vaccinationCertificate.birthDate else { return "" }
        return DateUtils.displayDateFormatter.string(from: date)
    }
    
    public var immunizationIcon: UIImage? {
        return UIImage(named: partialVaccination ? "status_partial" : "status_full", in: UIConstants.bundle, compatibleWith: nil)
    }
    
    public var immunizationTitle: String {
        return partialVaccination ? "vaccination_detail_immunization_partial_title".localized : "vaccination_detail_immunization_full_title".localized
    }
    
    public var immunizationBody: String {
        return partialVaccination ? "vaccination_detail_immunization_1_body".localized : "vaccination_detail_immunization_2_body".localized
    }
    
    public var immunizationButton: String {
        return partialVaccination ? "vaccination_detail_immunization_1_button".localized : "vaccination_detail_immunization_2_button".localized
    }

    public var vaccinations: [VaccinationViewModel] {
        return certificates.map({ VaccinationViewModel(certificate: $0.vaccinationCertificate) })
    }
}
