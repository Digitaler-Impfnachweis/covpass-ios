//
//  APIError.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum APIError: Error {
    case requestCancelled
    case compressionFailed
    case invalidUrl
    case invalidReponse
}
