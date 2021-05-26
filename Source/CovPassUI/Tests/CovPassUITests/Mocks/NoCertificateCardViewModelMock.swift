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
    var reuseIdentifier: String {
        "\(NoCertificateCollectionViewCell.self)"
    }
    
    var backgroundColor: UIColor {
        .backgroundSecondary20
    }
    
    var delegate: ViewModelDelegate?
    
    var title: String {
        "NoCertificate Title"
    }
    
    var subtitle: String {
        "NoCertificate Subtitle"
    }
    
    var image: UIImage {
        .scan
    }
}
