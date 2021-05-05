//
//  ExtendedVaccinationTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class ExtendedVaccinationTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("CBORWebToken")
        let sut = try! JSONDecoder().decode(CBORWebToken.self, from: jsonData)

        XCTAssertEqual(sut.iss, "DE")
        XCTAssertEqual(sut.iat?.timeIntervalSince1970, 1619167131)
        XCTAssertEqual(sut.exp?.timeIntervalSince1970, 1682239131)
        XCTAssertEqual(sut.hcert.dgc.ver, "1.0.0")
    }
}
