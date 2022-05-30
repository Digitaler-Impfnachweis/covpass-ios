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
    var iconTintColor: UIColor { get }
    var textColor: UIColor { get }
    var showBoosterAvailabilityNotification: Bool { get }
    var delegate: ViewModelDelegate? { get set }
}
