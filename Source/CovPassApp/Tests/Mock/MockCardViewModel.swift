//
//  MockCardViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

struct MockCardViewModel: CardViewModel {
    let showNotification: Bool = false
    
    let reuseIdentifier: String = "\(MockCardViewModel.self)"

    let backgroundColor: UIColor = .black

    let iconTintColor: UIColor = .white

    let textColor: UIColor = .black
    
    var delegate: ViewModelDelegate?
}
