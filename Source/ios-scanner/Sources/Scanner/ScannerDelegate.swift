//
//  ScannerDelegate.swift
//  
//
//  Created by Daniel on 29.03.2021.
//

import Foundation

public protocol ScannerDelegate: class {
    func result(with value: Result<String, ScanError>)
}
