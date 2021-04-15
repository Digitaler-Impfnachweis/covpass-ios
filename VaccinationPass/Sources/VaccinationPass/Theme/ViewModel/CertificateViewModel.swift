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

public class CertificateViewModel {
    
    // MARK: - Private
    
    private let parser: QRCodeProcessor = QRCodeProcessor()
    
    // MARK: - Internal
    
    weak var stateDelegate: CertificateStateDelegate?
    var certificateState: CertificateState = .none {
        didSet { stateDelegate?.didUpdatedCertificate(state: certificateState) }
    }
    var title: String { "Meine Impfungen" }
    
    var addButtonImage: UIImage? {
        UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil)
    }
    
    var titles = [
        "Wie nutze ich den digitalen Nachweis?",
        "Woher bekomme ich einen QR Code?",
        "Was passiert mit meinen Daten?"]
    
    func configure(cell: ActionCell, at indexPath: IndexPath) {
        cell.configure(title: titles[indexPath.row], iconName: UIConstants.IconName.ChevronRight)
    }
    
    func process(payload: String) {
        guard let decodedPayload = parser.parse(payload) else { return }
        print(decodedPayload)
        // Do more processes
        certificateState = .half
    }
    
    // MARK: - No Certificate Configuration
    let noCertificateCardTitle = "Nachweis hinzufügen"
    
    // MARK: - Half Certificate Configuration
    let halfCertificateCardTitle = "Nachweis hinzufügen"
    
    // MARK: - UIConfigureation
    
    let continerCornerRadius: CGFloat = 20
    let continerHeight: CGFloat = 200
    var headerButtonInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0)
}
