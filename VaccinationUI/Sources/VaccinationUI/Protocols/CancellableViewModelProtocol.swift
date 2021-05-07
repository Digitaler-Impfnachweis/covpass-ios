//
//  CancellableViewModelProtocol.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol CancellableViewModelProtocol {
    /// Should check if the viewmodel is in a state for cancellation
    func isCancellable() -> Bool

    /// Will cancel the current flow
    func cancel()
}

extension CancellableViewModelProtocol {
    public func isCancellable() -> Bool {
        true
    }
}
