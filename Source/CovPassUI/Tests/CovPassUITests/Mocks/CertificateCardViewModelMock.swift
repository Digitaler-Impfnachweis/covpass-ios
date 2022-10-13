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
    
    var maskStatusIsHidden: Bool = true
    
    var regionText: String? = nil
    
    let headerSubtitle: String? = nil
    
    let showNotification = false

    let isInvalid: Bool = false
        
    let reuseIdentifier: String = "\(CertificateCollectionViewCell.self)"

    let backgroundColor: UIColor = .onBrandAccent70

    let title: String = "Vaccination Title"

    let subtitle: String = "subtitle"

    let titleIcon: UIImage = .card
    
    let subtitleIcon: UIImage = .statusFullCircle

    let qrCode: UIImage? = .card

    let qrCodeTitle: String? = "QR Code Title"

    let name: String = "Vaccination Name"

    let tintColor: UIColor = .backgroundPrimary

    let iconTintColor: UIColor = .white

    let textColor: UIColor = .black
    
    var delegate: ViewModelDelegate?

    func onClickAction() {}
}
