//
//  VaccinationTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class VaccinationTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("Vaccination")
        let sut = try! JSONDecoder().decode(Vaccination.self, from: jsonData)

        XCTAssertEqual(sut.tg, "840539006")
        XCTAssertEqual(sut.vp, "1119349007")
        XCTAssertEqual(sut.mp, "EU/1/20/1528")
        XCTAssertEqual(sut.ma, "ORG-100030215")
        XCTAssertEqual(sut.dn, 2)
        XCTAssertEqual(sut.sd, 2)
        XCTAssertEqual(sut.dt, DateUtils.isoDateFormatter.date(from: "2021-02-02"))
        XCTAssertEqual(sut.co, "DE")
    }

    func testMapping() {
        let jsonData = Data.json("Vaccination")
        let sut = try! JSONDecoder().decode(Vaccination.self, from: jsonData)

        XCTAssertEqual(sut.map(key: sut.vp, from: Bundle.commonBundle.url(forResource: "sct-vaccines-covid-19", withExtension: "json")), "SARS-CoV-2 mRNA vaccine")
        XCTAssertEqual(sut.map(key: sut.mp, from: Bundle.commonBundle.url(forResource: "vaccine-medicinal-product", withExtension: "json")), "Comirnaty")
        XCTAssertEqual(sut.map(key: sut.ma, from: Bundle.commonBundle.url(forResource: "vaccines-covid-19-auth-holders", withExtension: "json")), "Biontech Manufacturing GmbH")
        XCTAssertEqual(sut.map(key: sut.co, from: Bundle.commonBundle.url(forResource: "country-2-codes", withExtension: "json")), "Germany")
    }

    func testBooster() {
        let jsonData = Data.json("Vaccination")
        let sut = try! JSONDecoder().decode(Vaccination.self, from: jsonData)
        sut.dt = Date()

        sut.mp = MedicalProduct.johnsonjohnson.rawValue
        sut.dn = 1
        XCTAssertFalse(sut.isBoosted)
        XCTAssertFalse(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.johnsonjohnson.rawValue
        sut.dn = 2
        XCTAssert(sut.isBoosted)
        XCTAssert(sut.fullImmunization)
        XCTAssert(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.johnsonjohnson.rawValue
        sut.dn = 3
        XCTAssert(sut.isBoosted)
        XCTAssert(sut.fullImmunization)
        XCTAssert(sut.fullImmunizationValid)

        sut.mp = MedicalProduct.biontech.rawValue
        sut.dn = 1
        XCTAssertFalse(sut.isBoosted)
        XCTAssertFalse(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.biontech.rawValue
        sut.dn = 2
        XCTAssertFalse(sut.isBoosted)
        XCTAssert(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.biontech.rawValue
        sut.dn = 3
        XCTAssert(sut.isBoosted)
        XCTAssert(sut.fullImmunization)
        XCTAssert(sut.fullImmunizationValid)

        sut.mp = MedicalProduct.astrazeneca.rawValue
        sut.dn = 1
        XCTAssertFalse(sut.isBoosted)
        XCTAssertFalse(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.astrazeneca.rawValue
        sut.dn = 2
        XCTAssertFalse(sut.isBoosted)
        XCTAssert(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.astrazeneca.rawValue
        sut.dn = 3
        XCTAssert(sut.isBoosted)
        XCTAssert(sut.fullImmunization)
        XCTAssert(sut.fullImmunizationValid)

        sut.mp = MedicalProduct.moderna.rawValue
        sut.dn = 1
        XCTAssertFalse(sut.isBoosted)
        XCTAssertFalse(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.moderna.rawValue
        sut.dn = 2
        XCTAssertFalse(sut.isBoosted)
        XCTAssert(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.moderna.rawValue
        sut.dn = 3
        XCTAssert(sut.isBoosted)
        XCTAssert(sut.fullImmunization)
        XCTAssert(sut.fullImmunizationValid)
    }
}
