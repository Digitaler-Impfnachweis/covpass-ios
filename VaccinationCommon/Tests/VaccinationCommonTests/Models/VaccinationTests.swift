//
//  VaccinationTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class VaccinationTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("Vaccination")
        let sut = try! JSONDecoder().decode(Vaccination.self, from: jsonData)

        XCTAssertEqual(sut.tg, "840539006")
        XCTAssertEqual(sut.vp, "1119349007")
        XCTAssertEqual(sut.mp, "EU/1/20/1528")
        XCTAssertEqual(sut.ma, "ORG-100030215")
        XCTAssertEqual(sut.dn, 2)
        XCTAssertEqual(sut.sd, 2)
        XCTAssertEqual(sut.dt, DateUtils.vaccinationDateFormatter.date(from: "2021-02-02"))
        XCTAssertEqual(sut.co, "DE")
    }
}
