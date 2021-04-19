//
//  VaccinationCertificateDTOTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class VaccinationCertificateDTOTests: XCTestCase {
    lazy var vaccinationCertificateDict: [String: Any] = {
        JsonSerializer.json(forResource: "VaccinationCertificateDTO")
    }()!

    func testInitSuccessful() {
        let vaccinationCertificate = VaccinationCertificateDTO(jsonDict: vaccinationCertificateDict)
        XCTAssertNotNil(vaccinationCertificate)
        XCTAssertEqual(vaccinationCertificate.name, "Mustermann Erika")
        XCTAssertEqual(vaccinationCertificate.birthDate, DateUtils.vaccinationDateFormatter.date(from: "19640812"))
        XCTAssertEqual(vaccinationCertificate.identifier, "C01X00T47")
        XCTAssertEqual(vaccinationCertificate.sex, Sex.female)
        XCTAssertNotNil(vaccinationCertificate.vaccination)
        XCTAssertEqual(vaccinationCertificate.issuer, "Landratsamt Altötting")
        XCTAssertEqual(vaccinationCertificate.id, "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S")
        XCTAssertEqual(vaccinationCertificate.validFrom, DateUtils.vaccinationDateFormatter.date(from: "20200202"))
        XCTAssertEqual(vaccinationCertificate.validUntil, DateUtils.vaccinationDateFormatter.date(from: "20230202"))
        XCTAssertEqual(vaccinationCertificate.version, "1.0.0")
        XCTAssertEqual(vaccinationCertificate.secret, "ZFKIYIBK39A3#S")
    }

    func testVaccination() {
        guard let extendedVaccination = VaccinationCertificateDTO(jsonDict: vaccinationCertificateDict).vaccination?.first else {
            XCTFail("ExtendedVaccination list should not be nil")
            return
        }
        XCTAssertEqual(extendedVaccination.vaccination.targetDisease, "U07.1!")
        XCTAssertEqual(extendedVaccination.vaccination.vaccineCode, "1119349007")
        XCTAssertEqual(extendedVaccination.vaccination.product, "COMIRNATY")
        XCTAssertEqual(extendedVaccination.vaccination.manufacturer, "BioNTech Manufacturing GmbH")
        XCTAssertEqual(extendedVaccination.vaccination.series, "2/2")
        XCTAssertEqual(extendedVaccination.vaccination.occurence, DateUtils.vaccinationDateFormatter.date(from: "20210202"))
        XCTAssertEqual(extendedVaccination.vaccination.country, "DE")
        XCTAssertEqual(extendedVaccination.lotNumber, "T654X4")
        XCTAssertEqual(extendedVaccination.location, "84503")
        XCTAssertEqual(extendedVaccination.performer, "999999900")
        XCTAssertEqual(extendedVaccination.nextDate, DateUtils.vaccinationDateFormatter.date(from: "20210402"))
    }
}
