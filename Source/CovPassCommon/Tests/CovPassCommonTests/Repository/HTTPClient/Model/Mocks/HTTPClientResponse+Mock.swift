//
//  HTTPClientResponse+Mock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation

extension HTTPClientResponse {
    static func mock(httpURLResponse: HTTPURLResponse = HTTPURLResponse(), data: Data? = nil) -> Self {
        Self(httpURLResponse: httpURLResponse, data: data)
    }
}
