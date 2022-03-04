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
    
    var sut: Vaccination!
    
    override func setUpWithError() throws {
        sut = Vaccination(tg: "", vp: "", mp: "", ma: "", dn: 1, sd: 1, dt: Date(), co: "", is: "", ci: "")
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testIsJohnsonJohnson() {
        // WHEN
        sut.mp = "EU/1/20/1525"
        // THEN
        XCTAssertTrue(sut.isJohnsonJohnson)
    }
    
    func testIsBiontech() {
        // WHEN
        sut.mp = "EU/1/20/1528"
        // THEN
        XCTAssertTrue(sut.isBiontech)
    }
    
    func testIsModerna() {
        // WHEN
        sut.mp = "EU/1/20/1507"
        // THEN
        XCTAssertTrue(sut.isModerna)
    }
    
    func testIsSingleDoseComplete() {
        // WHEN
        sut.dn = 1
        sut.sd = 1
        // THEN
        XCTAssertTrue(sut.isSingleDoseComplete)
    }
    
    func testIsDoubleDoseComplete() {
        // WHEN
        sut.dn = 2
        sut.sd = 2
        // THEN
        XCTAssertTrue(sut.isDoubleDoseComplete)
    }
    
    func testIsAstrazeneca() {
        // WHEN
        sut.mp = "EU/1/21/1529"
        // THEN
        XCTAssertTrue(sut.isAstrazeneca)
    }
    
    func testIsNotJohnsonJohnson() {
        // WHEN
        sut.mp = "FOO"
        // THEN
        XCTAssertFalse(sut.isJohnsonJohnson)
    }
    
    func testIsNotBiontech() {
        // WHEN
        sut.mp = "FOO"
        // THEN
        XCTAssertFalse(sut.isBiontech)
    }
    
    func testIsNotModerna() {
        // WHEN
        sut.mp = "FOO"
        // THEN
        XCTAssertFalse(sut.isModerna)
    }
    
    func testIsNotAstrazeneca() {
        // WHEN
        sut.mp = "FOO"
        // THEN
        XCTAssertFalse(sut.isAstrazeneca)
    }
    
    func testIsNotSingleDoseComplete() {
        // WHEN
        sut.dn = 2
        sut.sd = 1
        // THEN
        XCTAssertFalse(sut.isSingleDoseComplete)
    }
    
    func testIsNotSingleDoseComplete2() {
        // WHEN
        sut.dn = 1
        sut.sd = 2
        // THEN
        XCTAssertFalse(sut.isSingleDoseComplete)
    }
    
    func testIsNotDoubleDoseComplete() {
        // WHEN
        sut.dn = 1
        sut.sd = 2
        // THEN
        XCTAssertFalse(sut.isDoubleDoseComplete)
    }
    
    func testIsNotDoubleDoseComplete2() {
        // WHEN
        sut.dn = 2
        sut.sd = 1
        // THEN
        XCTAssertFalse(sut.isDoubleDoseComplete)
    }
    
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
        XCTAssertEqual(sut.map(key: sut.mp, from: Bundle.commonBundle.url(forResource: "vaccines-covid-19-names", withExtension: "json")), "Comirnaty")
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
