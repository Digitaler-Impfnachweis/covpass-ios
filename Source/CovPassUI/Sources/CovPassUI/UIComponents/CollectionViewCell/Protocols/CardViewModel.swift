//
//  CardViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public protocol CardViewModel {
    var reuseIdentifier: String { get }
    var backgroundColor: UIColor { get }
    var delegate: ViewModelDelegate? { get set }
}
