//
//  ViewModelDelegate.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol ViewModelDelegate: class {
    func viewModelDidUpdate()
    func viewModelUpdateDidFailWithError(_ error: Error)
}
