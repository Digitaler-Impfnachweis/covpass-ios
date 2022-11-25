//
//  HTTPClientResponse.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct HTTPClientResponse {
    public let httpURLResponse: HTTPURLResponse
    public let data: Data?
}
