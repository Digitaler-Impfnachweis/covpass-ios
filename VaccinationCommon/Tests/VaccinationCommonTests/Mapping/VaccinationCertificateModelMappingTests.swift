//
//  VaccinationCertificateModelMappingTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class VaccinationCertificateModelMappingTests: XCTestCase {
    var sut: VaccinationCertificateDTO!

    override func setUp() {
        super.setUp()
        sut = VaccinationCertificateDTO(jsonDict: JsonSerializer.json(forResource: "VaccinationCertificateDTO")!)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDTOToModel() {
        var vaccinationCertificate: VaccinationCertificate?
        do {
            vaccinationCertificate = try VaccinationCertificate(with: sut)
        } catch {
            XCTFail(error.localizedDescription)
        }

        XCTAssertEqual(vaccinationCertificate?.name, "Mustermann Erika")
        XCTAssertEqual(vaccinationCertificate?.birthDate, DateUtils.vaccinationDateFormatter.date(from: "19640812"))
        XCTAssertEqual(vaccinationCertificate?.identifier, "C01X00T47")
        XCTAssertEqual(vaccinationCertificate?.sex, Sex.female)
        XCTAssertNotNil(vaccinationCertificate?.vaccination)
        XCTAssertEqual(vaccinationCertificate?.issuer, "Landratsamt Altötting")
        XCTAssertEqual(vaccinationCertificate?.id, "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S")
        XCTAssertEqual(vaccinationCertificate?.validFrom, DateUtils.vaccinationDateFormatter.date(from: "20200202"))
        XCTAssertEqual(vaccinationCertificate?.validUntil, DateUtils.vaccinationDateFormatter.date(from: "20230202"))
        XCTAssertEqual(vaccinationCertificate?.version, "1.0.0")
        XCTAssertEqual(vaccinationCertificate?.secret, "ZFKIYIBK39A3#S")
    }

    func testDTOToModelVaccination() {
        var vaccinationCertificate: VaccinationCertificate?
        do {
            vaccinationCertificate = try VaccinationCertificate(with: sut)
        } catch {
            XCTFail(error.localizedDescription)
        }

        guard let extendedVaccination = vaccinationCertificate?.vaccination.first else {
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

    func testDTOToModel_withNameNil() {
        var vaccination: VaccinationCertificate?
        sut.name = nil
        do {
            vaccination = try VaccinationCertificate(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withIdentifierNil() {
        var vaccination: VaccinationCertificate?
        sut.identifier = nil
        do {
            vaccination = try VaccinationCertificate(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withVaccinationNil() {
        var vaccination: VaccinationCertificate?
        sut.vaccination = nil
        do {
            vaccination = try VaccinationCertificate(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withIssuerNil() {
        var vaccination: VaccinationCertificate?
        sut.issuer = nil
        do {
            vaccination = try VaccinationCertificate(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withIdNil() {
        var vaccination: VaccinationCertificate?
        sut.id = nil
        do {
            vaccination = try VaccinationCertificate(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withVersionNil() {
        var vaccination: VaccinationCertificate?
        sut.version = nil
        do {
            vaccination = try VaccinationCertificate(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withSecretNil() {
        var vaccination: VaccinationCertificate?
        sut.secret = nil
        do {
            vaccination = try VaccinationCertificate(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }
}
