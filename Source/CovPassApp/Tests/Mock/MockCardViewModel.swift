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
    var showNotification: Bool = false
    
    var delegate: ViewModelDelegate?

    var reuseIdentifier: String {
        "\(MockCardViewModel.self)"
    }

    var backgroundColor: UIColor {
        .black
    }

    var iconTintColor: UIColor {
        return .white
    }

    var textColor: UIColor {
        return .black
    }
}
