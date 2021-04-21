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
        let jsonData = Data.json("ExtendedVaccination")
        let sut = try! JSONDecoder().decode(ExtendedVaccination.self, from: jsonData)

        XCTAssertEqual(sut.targetDisease, "U07.1!")
        XCTAssertEqual(sut.vaccineCode, "1119349007")
        XCTAssertEqual(sut.product, "COMIRNATY")
        XCTAssertEqual(sut.manufacturer, "BioNTech Manufacturing GmbH")
        XCTAssertEqual(sut.series, "2/2")
        XCTAssertEqual(sut.occurence, DateUtils.vaccinationDateFormatter.date(from: "20210202"))
        XCTAssertEqual(sut.country, "DE")
        XCTAssertEqual(sut.lotNumber, "T654X4")
        XCTAssertEqual(sut.location, "84503")
        XCTAssertEqual(sut.performer, "999999900")
        XCTAssertEqual(sut.nextDate, DateUtils.vaccinationDateFormatter.date(from: "20210402"))
    }
}
