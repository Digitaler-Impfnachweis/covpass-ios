//
//  JsonConvertable.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol JsonConvertable {
    func asJson() throws -> [String: Any]
}
