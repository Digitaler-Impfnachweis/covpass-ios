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
//        let sut = try! JSONDecoder().decode(Vaccination.self, from: jsonData)
//
//        XCTAssertEqual(sut.tg, "U07.1!")
//        XCTAssertEqual(sut.vp, "1119349007")
//        XCTAssertEqual(sut.mp, "COMIRNATY")
//        XCTAssertEqual(sut.ma, "BioNTech Manufacturing GmbH")
//        XCTAssertEqual(sut.dn, 2)
//        XCTAssertEqual(sut.sd, 2)
//        XCTAssertEqual(sut.dt, DateUtils.vaccinationDateFormatter.date(from: "20210202"))
//        XCTAssertEqual(sut.co, "DE")
    }
}
