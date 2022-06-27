//
//  Array+VaccinationTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class ArrayVaccinationTests: XCTestCase {
    
    var sut: [Vaccination]!
    
    override func setUpWithError() throws {
        sut = [Vaccination(tg: "", vp: "", mp: "", ma: "", dn: 1, sd: 1, dt: Date(), co: "", is: "", ci: "1"),
               Vaccination(tg: "", vp: "", mp: "", ma: "", dn: 1, sd: 1, dt: Date() - 100, co: "", is: "", ci: "2"),
               Vaccination(tg: "", vp: "", mp: "", ma: "", dn: 1, sd: 1, dt: Date() - 1000, co: "", is: "", ci: "3"),
               Vaccination(tg: "", vp: "", mp: "", ma: "", dn: 1, sd: 1, dt: Date() + 1000, co: "", is: "", ci: "4")]
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }


    func testOldestVaccination() {
        // WHEN
        let oldestVaccination = sut.oldestVaccination
        
        // THEN
        XCTAssertEqual(oldestVaccination?.ci, "3")
    }
}
