//
//  Promise+Cancellable.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

enum PromiseCancellationError: Error {
    case cancellationHandled
}

extension PMKError {
    static let cancellationHandled: Error = PromiseCancellationError.cancellationHandled
}

public extension Resolver {
    func cancel() {
        reject(PMKError.cancelled)
    }
}

public extension Promise {
    func cancelled(_ body: @escaping () -> Void) -> Promise<T> {
        Promise<T>.init { (resolver: Resolver<T>) in
            self.pipe { result in
                switch result {
                case let .fulfilled(value):
                    resolver.fulfill(value)
                case let .rejected(error):
                    switch error {
                    case PMKError.cancelled:
                        body()
                        resolver.reject(PMKError.cancellationHandled)
                    default:
                        resolver.reject(error)
                    }
                }
            }
        }
    }

    @discardableResult
    func `catch`(_ body: @escaping (Error) -> Void) -> PMKFinalizer {
        `catch`(policy: .allErrorsExceptCancellation) { error in
            switch error {
            case PromiseCancellationError.cancellationHandled:
                // nothing to do
                break
            default:
                body(error)
            }
        }
    }

    func recover<U: Thenable>(_ body: @escaping (Error) -> U) -> Promise<T> where U.T == T {
        recover(policy: .allErrorsExceptCancellation, body)
    }
}

public extension Thenable {
    var isCancelled: Bool {
        error?.localizedDescription == PMKError.cancelled.localizedDescription
    }
}
