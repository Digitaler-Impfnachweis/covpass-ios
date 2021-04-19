//
//  ExtendedVaccinationModelMappingTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class ExtendedVaccinationModelMappingTests: XCTestCase {
    var sut: ExtendedVaccinationDTO!

    override func setUp() {
        super.setUp()
        sut = ExtendedVaccinationDTO(jsonDict: JsonSerializer.json(forResource: "ExtendedVaccinationDTO")!)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDTOToModel() {
        var extendedVaccination: ExtendedVaccination?
        do {
            extendedVaccination = try ExtendedVaccination(with: sut)
        } catch {
            XCTFail(error.localizedDescription)
        }

        XCTAssertEqual(extendedVaccination?.vaccination.targetDisease, "U07.1!")
        XCTAssertEqual(extendedVaccination?.vaccination.vaccineCode, "1119349007")
        XCTAssertEqual(extendedVaccination?.vaccination.product, "COMIRNATY")
        XCTAssertEqual(extendedVaccination?.vaccination.manufacturer, "BioNTech Manufacturing GmbH")
        XCTAssertEqual(extendedVaccination?.vaccination.series, "2/2")
        XCTAssertEqual(extendedVaccination?.vaccination.occurence, DateUtils.vaccinationDateFormatter.date(from: "20210202"))
        XCTAssertEqual(extendedVaccination?.vaccination.country, "DE")
        XCTAssertEqual(extendedVaccination?.lotNumber, "T654X4")
        XCTAssertEqual(extendedVaccination?.location, "84503")
        XCTAssertEqual(extendedVaccination?.performer, "999999900")
        XCTAssertEqual(extendedVaccination?.nextDate, DateUtils.vaccinationDateFormatter.date(from: "20210402"))
    }

    func testDTOToModel_withVaccinationNil() {
        var vaccination: ExtendedVaccination?
        sut.vaccination = nil
        do {
            vaccination = try ExtendedVaccination(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withLotNumberNil() {
        var vaccination: ExtendedVaccination?
        sut.lotNumber = nil
        do {
            vaccination = try ExtendedVaccination(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withLocationNil() {
        var vaccination: ExtendedVaccination?
        sut.location = nil
        do {
            vaccination = try ExtendedVaccination(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withPerformerNil() {
        var vaccination: ExtendedVaccination?
        sut.performer = nil
        do {
            vaccination = try ExtendedVaccination(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }
}
