//
//  CellConfigutation.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol CellConfigutation {
    associatedtype T
    func configure(with configuration: T)
}
