//
//  ExtendedVaccinationDTOTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class ExtendedVaccinationDTOTests: XCTestCase {
    lazy var extendedVaccinationDict: [String: Any] = {
        JsonSerializer.json(forResource: "ExtendedVaccinationDTO")
    }()!

    func testInitSuccessful() {
        let extendedVaccination = ExtendedVaccinationDTO(jsonDict: extendedVaccinationDict)
        XCTAssertNotNil(extendedVaccination)
        XCTAssertEqual(extendedVaccination.vaccination?.targetDisease, "U07.1!")
        XCTAssertEqual(extendedVaccination.vaccination?.vaccineCode, "1119349007")
        XCTAssertEqual(extendedVaccination.vaccination?.product, "COMIRNATY")
        XCTAssertEqual(extendedVaccination.vaccination?.manufacturer, "BioNTech Manufacturing GmbH")
        XCTAssertEqual(extendedVaccination.vaccination?.series, "2/2")
        XCTAssertEqual(extendedVaccination.vaccination?.occurence, DateUtils.vaccinationDateFormatter.date(from: "20210202"))
        XCTAssertEqual(extendedVaccination.vaccination?.country, "DE")
        XCTAssertEqual(extendedVaccination.lotNumber, "T654X4")
        XCTAssertEqual(extendedVaccination.location, "84503")
        XCTAssertEqual(extendedVaccination.performer, "999999900")
        XCTAssertEqual(extendedVaccination.nextDate, DateUtils.vaccinationDateFormatter.date(from: "20210402"))
    }
}
