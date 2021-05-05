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

public class ScanPopupViewModel {
    // MARK - Properties

    let resolver: Resolver<ScanResult>

    // MARK - PopupRouter

    let height: CGFloat = UIScreen.main.bounds.height - 100
    let topCornerRadius: CGFloat = 20
    let presentDuration: Double = 0.5
    let dismissDuration: Double = 0.5
    let shouldDismissInteractivelty: Bool = true

    // MARK - Lifecycle

    public init(resolvable: Resolver<ScanResult>) {
        self.resolver = resolvable
    }

    func onResult(_ result: ScanResult) {
        resolver.fulfill(result)
    }

    func cancel() {
        resolver.cancel()
    }
}
