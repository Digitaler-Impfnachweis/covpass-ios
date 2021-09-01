//
//  MockExtendedCBORWebToken.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
import CovPassCommon

extension ExtendedCBORWebToken {

    // Quick hack to provide a testable web token
    static func mock() throws -> Self {
        let data = try XCTUnwrap("".data(using: .utf8))
        return try JSONDecoder().decode(ExtendedCBORWebToken.self, from: data)
    }
}
