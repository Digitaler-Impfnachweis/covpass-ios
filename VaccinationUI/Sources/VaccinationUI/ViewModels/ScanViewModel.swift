//
//  ProofPopupViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import Scanner

public typealias ScanResult = Swift.Result<String, ScanError>

public class ScanViewModel: CancellableViewModelProtocol {
    // MARK - Properties

    let resolver: Resolver<ScanResult>

    // MARK - Lifecycle

    public init(resolvable: Resolver<ScanResult>) {
        self.resolver = resolvable
    }

    public func onResult(_ result: ScanResult) {
        resolver.fulfill(result)
    }

    public func cancel() {
        resolver.cancel()
    }
}
