//
//  PromiseKit+Firstly.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit

public func firstly(_ body: () -> Void) -> Guarantee<Void> {
    return .value(body())
}
