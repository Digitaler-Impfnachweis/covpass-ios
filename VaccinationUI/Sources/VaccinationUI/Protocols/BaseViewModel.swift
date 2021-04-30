//
//  BaseViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol BaseViewModel {
    var image: UIImage? { get }
    var title: String { get }
    var info: String { get }
    var backgroundColor: UIColor { get }
}
