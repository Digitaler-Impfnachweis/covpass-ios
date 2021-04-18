//
//  VaccinationDetailViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

public struct VaccinationDetailViewModel {
    
    public var name: String {
        return "Max Mustermann"
    }
    
    public var partialVaccination: Bool {
        return true
    }
    
    public var immunizationIcon: UIImage? {
        return UIImage(named: partialVaccination ? "status_partial" : "status_full", in: UIConstants.bundle, compatibleWith: nil)
    }
    
    public var immunizationText: String {
        return partialVaccination ? "Impfschutz vollständig" : "Impfschutz vollständig"
    }
    
    public var immunizationBody: String {
        return partialVaccination ? "Weisen Sie Ihren Impfschutz mit dem Impfnachweis nach. Der Nachweis enthält nur Ihren Namen und Ihr Geburtsdatum." : "Weisen Sie Ihren Impfschutz mit dem Impfnachweis nach. Der Nachweis enthält nur Ihren Namen und Ihr Geburtsdatum."
    }
    
    public var immunizationTicketButton: String {
        return partialVaccination ? "Vorläufigen Impfnachweis anzeigen" : "Impfnachweis anzeigen"
    }
}
