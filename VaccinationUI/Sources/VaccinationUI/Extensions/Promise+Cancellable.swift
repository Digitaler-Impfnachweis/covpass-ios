//
//  Promise+Cancellable.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import PromiseKit

enum PromiseCancellationError: Error {
    case cancellationHandled
}

extension PMKError {
    static let cancellationHandled: Error = PromiseCancellationError.cancellationHandled
}

extension Resolver {
    public func cancel() {
        reject(PMKError.cancelled)
    }
}

extension Promise {
    public func cancelled(_ body: @escaping () -> Void) -> Promise<T> {
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
    public func `catch`(_ body: @escaping (Error) -> Void) -> PMKFinalizer {
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

    public func recover<U: Thenable>(_ body: @escaping (Error) -> U) -> Promise<T> where U.T == T {
        recover(policy: .allErrorsExceptCancellation, body)
    }
}

extension Thenable {
    public var isCancelled: Bool {
        error?.localizedDescription == PMKError.cancelled.localizedDescription
    }
}
