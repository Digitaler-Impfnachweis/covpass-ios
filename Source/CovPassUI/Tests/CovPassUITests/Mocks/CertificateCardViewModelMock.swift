//
//  CertificateCardViewModelMock.swift
//  
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class CertificateCardViewModelMock: CertificateCardViewModelProtocol {
    var reuseIdentifier: String {
        "\(CertificateCollectionViewCell.self)"
    }
    
    var backgroundColor: UIColor {
        .onBrandAccent70
    }
    
    var delegate: ViewModelDelegate?
    
    var title: String {
        "Vaccination Title"
    }

    var subtitle: String {
        "subtitle"
    }

    var titleIcon: UIImage {
        .card
    }
    
    var isFavorite: Bool = true
    
    var qrCode: UIImage? {
        .card
    }
    
    var qrCodeTitle: String? {
        "QR Code Title"
    }
    
    var name: String {
        "Vaccination Name"
    }
    
    var actionTitle: String {
        "Action Title"
    }
    
    var actionImage: UIImage {
        .scan
    }
    
    var tintColor: UIColor {
        .backgroundPrimary
    }
    
    var isFullImmunization: Bool = true
    
    var vaccinationDate: Date?
        
    func onClickAction() {}
    
    func onClickFavorite() {
        isFavorite.toggle()
    }
}
