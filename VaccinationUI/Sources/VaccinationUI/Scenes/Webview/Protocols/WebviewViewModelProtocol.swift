//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 06.05.21.
//

import Foundation

public protocol WebviewViewModelProtocol {
    var title: String? { get }
    var urlRequest: URLRequest { get }
}
