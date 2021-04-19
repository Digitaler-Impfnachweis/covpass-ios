//
//  ValidatorViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationUI
import UIKit
import VaccinationCommon

public class ValidatorViewModel {
    
    // MARK: - Private
    
    private let parser: QRCoder = QRCoder()
    
    // MARK: - Internal
    
    var title: String { "Prüf-App" }
    
    var titles = [
        "Wie nutze ich den digitalen Nachweis?",
        "Woher bekomme ich einen QR Code?",
        "Was passiert mit meinen Daten?"]
    
    func configure(cell: ActionCell, at indexPath: IndexPath) {
        cell.configure(title: titles[indexPath.row], iconName: UIConstants.IconName.ChevronRight)
    }
    
    func process(payload: String, completion: ((Error) -> Void)? = nil) {
        guard let decodedPayload = parser.parse(payload, completion: completion) else { return }
        print(decodedPayload)
        // Do more processes
//        certificateState = .half
    }
    
    // MARK: - UIConfigureation
    
    let continerCornerRadius: CGFloat = 20
    let continerHeight: CGFloat = 200
    var headerButtonInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0)
}
