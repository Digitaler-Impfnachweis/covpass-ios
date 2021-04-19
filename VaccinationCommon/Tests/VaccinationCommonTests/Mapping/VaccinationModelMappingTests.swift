//
//  VaccinationModelMappingTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class VaccinationModelMappingTests: XCTestCase {
    var sut: VaccinationDTO!

    override func setUp() {
        super.setUp()
        sut = VaccinationDTO(jsonDict: JsonSerializer.json(forResource: "VaccinationDTO")!)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDTOToModel() {
        var vaccination: Vaccination?
        do {
            vaccination = try Vaccination(with: sut)
        } catch {
            XCTFail(error.localizedDescription)
        }

        XCTAssertEqual(vaccination?.targetDisease, "U07.1!")
        XCTAssertEqual(vaccination?.vaccineCode, "1119349007")
        XCTAssertEqual(vaccination?.product, "COMIRNATY")
        XCTAssertEqual(vaccination?.manufacturer, "BioNTech Manufacturing GmbH")
        XCTAssertEqual(vaccination?.series, "2/2")
        XCTAssertEqual(vaccination?.occurence, DateUtils.vaccinationDateFormatter.date(from: "20210202"))
        XCTAssertEqual(vaccination?.country, "DE")
    }

    func testDTOToModel_withTargetDiseaseNil() {
        var vaccination: Vaccination?
        sut.targetDisease = nil
        do {
            vaccination = try Vaccination(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withVaccineCodeNil() {
        var vaccination: Vaccination?
        sut.vaccineCode = nil
        do {
            vaccination = try Vaccination(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withProductNil() {
        var vaccination: Vaccination?
        sut.product = nil
        do {
            vaccination = try Vaccination(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withManufacturerNil() {
        var vaccination: Vaccination?
        sut.manufacturer = nil
        do {
            vaccination = try Vaccination(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withSeriesNil() {
        var vaccination: Vaccination?
        sut.series = nil
        do {
            vaccination = try Vaccination(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }

    func testDTOToModel_withCountryNil() {
        var vaccination: Vaccination?
        sut.country = nil
        do {
            vaccination = try Vaccination(with: sut)
        } catch {
           XCTAssertTrue(error is ApplicationError)
        }
        XCTAssertNil(vaccination, "Model should be nil")
    }
}
