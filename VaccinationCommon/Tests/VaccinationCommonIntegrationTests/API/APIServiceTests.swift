//
//  APIServiceTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Compression
import Foundation
import SwiftCBOR
@testable import VaccinationCommon
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
