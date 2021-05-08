//
//  ScanViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import Scanner
import UIKit

public typealias ScanResult = Swift.Result<String, ScanError>

public class ScanViewModel: CancellableViewModelProtocol {
    // MARK: - Properties

    let resolver: Resolver<ScanResult>

    // MARK: - Lifecycle

    public init(resolvable: Resolver<ScanResult>) {
        resolver = resolvable
    }

    public func onResult(_ result: ScanResult) {
        resolver.fulfill(result)
    }

    public func cancel() {
        resolver.cancel()
    }
}
