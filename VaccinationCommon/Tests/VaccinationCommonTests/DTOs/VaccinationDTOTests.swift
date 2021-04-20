//
//  VaccinationDTOTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class VaccinationDTOTests: XCTestCase {
    lazy var vaccinationDict: [String: Any] = {
        JsonSerializer.json(forResource: "VaccinationDTO")
    }()!

    func testInitSuccessful() {
        let vaccination = VaccinationDTO(jsonDict: vaccinationDict)
        XCTAssertNotNil(vaccination)
        XCTAssertEqual(vaccination.targetDisease, "U07.1!")
        XCTAssertEqual(vaccination.vaccineCode, "1119349007")
        XCTAssertEqual(vaccination.product, "COMIRNATY")
        XCTAssertEqual(vaccination.manufacturer, "BioNTech Manufacturing GmbH")
        XCTAssertEqual(vaccination.series, "2/2")
        XCTAssertEqual(vaccination.occurence, DateUtils.vaccinationDateFormatter.date(from: "20210202"))
        XCTAssertEqual(vaccination.country, "DE")
    }
}
