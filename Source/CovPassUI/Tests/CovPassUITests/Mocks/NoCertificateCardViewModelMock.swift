//
//  NoCertificateCardViewModelMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class NoCertificateCardViewModelMock: NoCertificateCardViewModelProtocol {
    
    let showNotification = false
    
    let reuseIdentifier: String = "\(NoCertificateCollectionViewCell.self)"

    let backgroundColor: UIColor = .backgroundSecondary20

    let title: String = "NoCertificate Title"

    let subtitle: String = "NoCertificate Subtitle"

    let image: UIImage = .scan

    let iconTintColor: UIColor = .white

    let textColor: UIColor = .black
    
    var delegate: ViewModelDelegate?

}
