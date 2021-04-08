//
//  CertificateViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationUI
import UIKit

public struct CertificateViewModel {
    
    var title: String {
        "Meine Impfnachweise"
    }
    
    var addButtonImage: UIImage? {
        UIImage(named: "plus", in: UIConstants.bundle, compatibleWith: nil)
    }
    
    public var titles = [
        "Wie nutze ich den digitalen Nachweis?",
        "Woher bekomme ich einen QR Code?",
        "Was passiert mit meinen Daten?"]
    
    func configure(cell: ActionCell, at indexPath: IndexPath) {
        cell.configure(title: titles[indexPath.row], iconName: "chevron--right")
    }
}
