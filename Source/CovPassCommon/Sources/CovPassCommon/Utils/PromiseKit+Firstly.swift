//
//  PromiseKit+Firstly.swift
//  
//
//  Created by Fatih Karakurt on 10.12.21.
//

import PromiseKit

public func firstly(_ body: () -> Void) -> Guarantee<Void> {
    return .value(body())
}
