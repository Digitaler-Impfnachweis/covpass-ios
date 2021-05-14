//
//  CancellableViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol CancellableViewModelProtocol {
    /// Should check if the viewmodel is in a state for cancellation
    func isCancellable() -> Bool

    /// Will cancel the current flow
    func cancel()
}

public extension CancellableViewModelProtocol {
    func isCancellable() -> Bool {
        true
    }
}
