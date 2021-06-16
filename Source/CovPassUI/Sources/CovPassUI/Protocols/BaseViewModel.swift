//
//  BaseViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public protocol BaseViewModel {
    var delegate: ViewModelDelegate? { get set }
}
