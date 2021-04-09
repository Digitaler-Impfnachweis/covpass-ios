//
//  CertificateViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationUI
import UIKit
import VaccinationCommon

public struct CertificateViewModel {
    
    let parser: QRCodeProcessor = QRCodeProcessor()
    
    var title: String {
        "Meine Impfnachweise"
    }
    
    var addButtonImage: UIImage? {
        UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil)
    }
    
    public var titles = [
        "Wie nutze ich den digitalen Nachweis?",
        "Woher bekomme ich einen QR Code?",
        "Was passiert mit meinen Daten?"]
    
    func configure(cell: ActionCell, at indexPath: IndexPath) {
        cell.configure(title: titles[indexPath.row], iconName: UIConstants.IconName.ChevronRight)
    }
    
    func process(payload: String) -> String {
        parser.parse(payload) ?? ""
    }
}
