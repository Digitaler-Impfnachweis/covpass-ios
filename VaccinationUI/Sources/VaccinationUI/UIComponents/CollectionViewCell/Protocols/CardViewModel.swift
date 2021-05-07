//
//  CardViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol CardViewModel {
    var reuseIdentifier: String { get }
    var backgroundColor: UIColor { get }
}
