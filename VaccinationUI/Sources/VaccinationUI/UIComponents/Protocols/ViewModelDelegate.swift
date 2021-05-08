//
//  ViewModelDelegate.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol ViewModelDelegate: AnyObject {
    func viewModelDidUpdate()
    func viewModelUpdateDidFailWithError(_ error: Error)
}
