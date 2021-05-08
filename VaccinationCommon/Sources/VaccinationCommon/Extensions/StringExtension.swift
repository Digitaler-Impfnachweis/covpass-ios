//
//  StringExtension.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

let HC1 = "HC1:"

public extension String {
    func stripPrefix() -> String {
        if starts(with: HC1) {
            return String(dropFirst(4))
        }
        return self
    }
}
