//
//  MockCardViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import VaccinationUI

struct MockCardViewModel: CardViewModel {
    var delegate: ViewModelDelegate?

    var reuseIdentifier: String {
        "\(MockCardViewModel.self)"
    }

    var backgroundColor: UIColor {
        .black
    }
}
