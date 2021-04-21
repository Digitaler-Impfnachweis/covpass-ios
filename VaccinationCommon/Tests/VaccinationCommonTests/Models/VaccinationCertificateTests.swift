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
        let sut = try! JSONDecoder().decode(VaccinationCertificate.self, from: jsonData)

        XCTAssertEqual(sut.name, "Mustermann Erika")
        XCTAssertEqual(sut.birthDate, DateUtils.vaccinationDateFormatter.date(from: "19640812"))
        XCTAssertEqual(sut.identifier, "C01X00T47")
        XCTAssertEqual(sut.sex, Sex.female)
        XCTAssertNotNil(sut.vaccination)
        XCTAssertEqual(sut.issuer, "Landratsamt Altötting")
        XCTAssertEqual(sut.id, "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S")
        XCTAssertEqual(sut.validFrom, DateUtils.vaccinationDateFormatter.date(from: "20200202"))
        XCTAssertEqual(sut.validUntil, DateUtils.vaccinationDateFormatter.date(from: "20230202"))
        XCTAssertEqual(sut.version, "1.0.0")
        XCTAssertEqual(sut.secret, "ZFKIYIBK39A3#S")
    }
}
