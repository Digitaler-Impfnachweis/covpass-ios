//
//  ViewModelDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol ViewModelDelegate: AnyObject {
    func viewModelDidUpdate()
    func viewModelUpdateDidFailWithError(_ error: Error)
}
