//
//  APIError.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum APIError: Error, ErrorCode {
    case requestCancelled
    case compressionFailed
    case invalidUrl
    case invalidResponse

    public var errorCode: Int {
        switch self {
        case .requestCancelled:
            return 101
        case .compressionFailed:
            return 102
        case .invalidUrl:
            return 103
        case .invalidResponse:
            return 104
        }
    }
}
