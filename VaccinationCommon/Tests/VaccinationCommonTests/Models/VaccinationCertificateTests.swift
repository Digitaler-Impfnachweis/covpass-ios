//
//  VaccinationCertificateTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class VaccinationCertificateTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("VaccinationCertificate")
//        let sut = try! JSONDecoder().decode(DigitalGreenCertificate.self, from: jsonData)
//
//        XCTAssertEqual(sut.nam.fnt, "Mustermann Erika")
//        XCTAssertNotNil(sut.vaccination)
//        XCTAssertEqual(sut.issuer, "Landratsamt Altötting")
//        XCTAssertEqual(sut.id, "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S")
//        XCTAssertEqual(sut.validFrom, DateUtils.vaccinationDateFormatter.date(from: "20200202"))
//        XCTAssertEqual(sut.validUntil, DateUtils.vaccinationDateFormatter.date(from: "20230202"))
//        XCTAssertEqual(sut.version, "1.0.0")
    }
}
