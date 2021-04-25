//
//  ValidationCertificateTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class ValidationCertificateTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("ValidationCertificate")
        let sut = try! JSONDecoder().decode(ValidationCertificate.self, from: jsonData)

        XCTAssertEqual(sut.name, "Mustermann Erika")
        XCTAssertEqual(sut.birthDate, DateUtils.vaccinationDateFormatter.date(from: "19640812")!)
        XCTAssertEqual(sut.issuer, "Landratsamt Altötting")
        XCTAssertEqual(sut.id, "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S")
        XCTAssertEqual(sut.validUntil, DateUtils.vaccinationDateFormatter.date(from: "20230202")!)
        XCTAssertEqual(sut.vaccination.count, 1)
        XCTAssertEqual(sut.vaccination.first!.targetDisease, "U07.1!")
        XCTAssertEqual(sut.vaccination.first!.vaccineCode, "1119349007")
        XCTAssertEqual(sut.vaccination.first!.product, "COMIRNATY")
        XCTAssertEqual(sut.vaccination.first!.manufacturer, "BioNTech Manufacturing GmbH")
        XCTAssertEqual(sut.vaccination.first!.series, "2/2")
        XCTAssertEqual(sut.vaccination.first!.occurrence, DateUtils.vaccinationDateFormatter.date(from: "20210202")!)
        XCTAssertEqual(sut.vaccination.first!.country, "DE")
    }
}
