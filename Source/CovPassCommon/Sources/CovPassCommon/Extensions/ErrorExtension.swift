//
//  ErrorExtension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol ErrorCode {
    var errorCode: Int { get }
}

public extension Error {
    func displayCodeWithMessage(_ msg: String) -> String {
        if let errorWithCode = self as? ErrorCode {
            return "\(msg) (Error \(errorWithCode.errorCode))"
        }
        return msg
    }
}
