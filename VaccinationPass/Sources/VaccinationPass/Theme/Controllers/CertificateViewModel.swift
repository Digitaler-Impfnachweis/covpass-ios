//
//  CertificateViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationUI

public struct CertificateViewModel {
    
    public var titles = [
        "Wie nutze ich den digitalen Nachweis?",
        "Woher bekomme ich einen QR Code?",
        "Was passiert mit meinen Daten?"]
    
    func configure(cell: ActionCell, at indexPath: IndexPath) {
        cell.configure(title: titles[indexPath.row], iconName: "chevron--right")
    }
}
