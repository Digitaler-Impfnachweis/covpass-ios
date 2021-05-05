//
//  StringExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

let HC1 = "HC1:"

public extension String {
    public func stripPrefix() -> String {
        if self.starts(with: HC1) {
            return String(self.dropFirst(4))
        }
        return self
    }
}
