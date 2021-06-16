//
//  DefaultScannerDelegate.swift
//
//
//  Created by Daniel on 29.03.2021.
//

import Foundation
import Scanner

class DefaultScannerDelegate: ScannerDelegate {
    var resultCalled = false

    func result(with _: Result<String, ScanError>) {
        resultCalled = true
    }
}
