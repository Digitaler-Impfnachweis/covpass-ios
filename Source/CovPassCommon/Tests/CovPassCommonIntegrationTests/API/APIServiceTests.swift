//
//  APIServiceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Compression
import Foundation
import SwiftCBOR
@testable import CovPassCommon
import XCTest

class APIServiceTests: XCTestCase {
    var sut: APIService!

    override func setUp() {
        super.setUp()
        sut = APIService(
            sessionDelegate: APIServiceDelegate(
                certUrl: Bundle.module.url(forResource: "rsa-certify.demo.ubirch.com", withExtension: "der")!
            ),
            url: ""
        )
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
}
