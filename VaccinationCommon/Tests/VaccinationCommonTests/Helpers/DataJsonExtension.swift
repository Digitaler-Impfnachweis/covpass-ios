//
//  DataJsonExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension Data {
    static func json(_ resource: String) -> Data {
        let url = Bundle.module.url(forResource: resource, withExtension: "json")!
        return try! String(contentsOf: url, encoding: .utf8).data(using: .utf8)!
    }
}
