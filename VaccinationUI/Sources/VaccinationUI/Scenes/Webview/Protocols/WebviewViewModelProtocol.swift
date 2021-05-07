//
//  WebviewViewModelProtocol.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol WebviewViewModelProtocol {
    var title: String? { get }
    var urlRequest: URLRequest { get }
}
