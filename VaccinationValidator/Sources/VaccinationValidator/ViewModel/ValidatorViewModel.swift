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
import PromiseKit

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

    public func process(payload: String) -> Promise<ValidationCertificate> {
        return Promise<ValidationCertificate>() { seal in
            // TODO refactor parser
            guard let decodedPayload: ValidationCertificate = parser.parse(payload, completion: { error in
                seal.reject(error)
            }) else {
                seal.reject(ApplicationError.unknownError)
                return
            }
            seal.fulfill(decodedPayload)
        }
    }
    
    // MARK: - UIConfigureation
    
    let continerCornerRadius: CGFloat = 20
    let continerHeight: CGFloat = 200
    var headerButtonInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0)
}
