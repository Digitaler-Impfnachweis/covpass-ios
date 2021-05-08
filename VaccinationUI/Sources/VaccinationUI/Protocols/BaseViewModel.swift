//
//  BaseViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol BaseViewModel {
    var delegate: ViewModelDelegate? { get set }
}
