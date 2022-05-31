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
    var dtDate: Date!
    var vac1Of1JJ: Vaccination!
    var vac2Of1Biontech: Vaccination!
    var vac2Of2Moderna: Vaccination!

    override func setUpWithError() throws {
        dtDate = Date()
        sut = Vaccination(tg: "", vp: "", mp: "", ma: "", dn: 1, sd: 1, dt: dtDate, co: "", is: "", ci: "")
        vac1Of1JJ = Vaccination(tg: "", vp: "",
                                mp: MedicalProduct.johnsonjohnson.rawValue,
                                ma: "",
                                dn: 1,
                                sd: 1,
                                dt: Date(),
                                co: "",
                                is: "",
                                ci: "1")
        vac2Of1Biontech = Vaccination(tg: "",
                                         vp: "",
                                         mp: MedicalProduct.biontech.rawValue,
                                         ma: "",
                                         dn: 2,
                                         sd: 1,
                                         dt: Date(),
                                         co: "",
                                         is: "",
                                         ci: "2")
        vac2Of2Moderna = Vaccination(tg: "",
                                         vp: "",
                                         mp: MedicalProduct.moderna.rawValue,
                                         ma: "",
                                         dn: 2,
                                         sd: 2,
                                         dt: Date(),
                                         co: "",
                                         is: "",
                                         ci: "2")
    }
    
    override func tearDownWithError() throws {
        dtDate = nil
        sut = nil
        vac1Of1JJ = nil
        vac2Of1Biontech = nil
    }
    
    func testIs2Of1() {
        // WHEN
        sut.sd = 1
        sut.dn = 2
        // THEN
        XCTAssertTrue(sut.is2Of1)
    }
    
    func testIsNot2Of1() {
        // WHEN
        sut.sd = 2
        sut.dn = 1
        // THEN
        XCTAssertFalse(sut.is2Of1)
    }
    
    func testIsJohnsonJohnson() {
        // WHEN
        sut.mp = "EU/1/20/1525"
        // THEN
        XCTAssertTrue(sut.isJohnsonJohnson)
    }
    
    func testIsJohnsonJohnsonAndSingleDoseComplete() {
        // WHEN
        sut.mp = "EU/1/20/1525"
        sut.sd = 1
        sut.dn = 1
        
        // THEN
        XCTAssertTrue(sut.isJohnsonJohnsonWithSingleDoseComplete)
    }
    
    func testIsJohnsonJohnsonAndSingleDoseNotComplete() {
        // WHEN
        sut.mp = "EU/1/20/1525"
        sut.sd = 1
        sut.dn = 0
        
        // THEN
        XCTAssertFalse(sut.isJohnsonJohnsonWithSingleDoseComplete)
    }
    
    func testIsNotJohnsonJohnsonAndSingleDoseComplete() {
        // WHEN
        sut.mp = "Something"
        sut.sd = 1
        sut.dn = 1
        
        // THEN
        XCTAssertFalse(sut.isJohnsonJohnsonWithSingleDoseComplete)
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
        XCTAssertFalse(sut.isBoosted())
        XCTAssertFalse(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.johnsonjohnson.rawValue
        sut.dn = 2
        XCTAssert(sut.isBoosted())
        XCTAssert(sut.fullImmunization)
        XCTAssert(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.johnsonjohnson.rawValue
        sut.dn = 3
        XCTAssert(sut.isBoosted())
        XCTAssert(sut.fullImmunization)
        XCTAssert(sut.fullImmunizationValid)
        
        sut.mp = MedicalProduct.biontech.rawValue
        sut.dn = 1
        XCTAssertFalse(sut.isBoosted())
        XCTAssertFalse(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.biontech.rawValue
        sut.dn = 2
        XCTAssertFalse(sut.isBoosted())
        XCTAssert(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.biontech.rawValue
        sut.dn = 3
        XCTAssert(sut.isBoosted())
        XCTAssert(sut.fullImmunization)
        XCTAssert(sut.fullImmunizationValid)
        
        sut.mp = MedicalProduct.astrazeneca.rawValue
        sut.dn = 1
        XCTAssertFalse(sut.isBoosted())
        XCTAssertFalse(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.astrazeneca.rawValue
        sut.dn = 2
        XCTAssertFalse(sut.isBoosted())
        XCTAssert(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.astrazeneca.rawValue
        sut.dn = 3
        XCTAssert(sut.isBoosted())
        XCTAssert(sut.fullImmunization)
        XCTAssert(sut.fullImmunizationValid)
        
        sut.mp = MedicalProduct.moderna.rawValue
        sut.dn = 1
        XCTAssertFalse(sut.isBoosted())
        XCTAssertFalse(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.moderna.rawValue
        sut.dn = 2
        XCTAssertFalse(sut.isBoosted())
        XCTAssert(sut.fullImmunization)
        XCTAssertFalse(sut.fullImmunizationValid)
        sut.mp = MedicalProduct.moderna.rawValue
        sut.dn = 3
        XCTAssert(sut.isBoosted())
        XCTAssert(sut.fullImmunization)
        XCTAssert(sut.fullImmunizationValid)
    }
    
    func testDowngrade2OutOf1ToBasisImmunization() {
        let shouldDowngraded = vac2Of1Biontech.downgrade2OutOf1ToBasisImmunization(otherCertificatesInTheUsersChain: [vac1Of1JJ],
                                                                                      recoveries: nil)
        XCTAssertTrue(vac2Of1Biontech.isBoosted())
        XCTAssertTrue(shouldDowngraded)
    }
    
    func testDowngrade2OutOf1ToBasisImmunizationAndRecoveryAsOldest() {
        let recovery = Recovery(tg: "",
                                fr: Date() - 100,
                                df: Date(),
                                du: Date(),
                                co: "",
                                is: "",
                                ci: "3")
        
        let shouldDowngraded = vac2Of1Biontech.downgrade2OutOf1ToBasisImmunization(otherCertificatesInTheUsersChain: [vac1Of1JJ],
                                                                                      recoveries: [recovery])
        XCTAssertTrue(vac2Of1Biontech.isBoosted())
        XCTAssertFalse(shouldDowngraded)
    }
    
    func testDowngrade2OutOf1ToBasisImmunizationAndRecoveryAsNotOldest() {
        let recovery = Recovery(tg: "",
                                fr: Date() + 100,
                                df: Date(),
                                du: Date(),
                                co: "",
                                is: "",
                                ci: "3")
        
        let shouldDowngraded = vac2Of1Biontech.downgrade2OutOf1ToBasisImmunization(otherCertificatesInTheUsersChain: [vac1Of1JJ],
                                                                                      recoveries: [recovery])
        XCTAssertTrue(vac2Of1Biontech.isBoosted())
        XCTAssertTrue(shouldDowngraded)
    }
    
    func testDowngrade2OutOf1ToBasisImmunizationWithBoosterCert() {
        let someBooster = Vaccination(tg: "", vp: "",
                                mp: MedicalProduct.johnsonjohnson.rawValue,
                                ma: "",
                                dn: 3,
                                sd: 3,
                                dt: Date(),
                                co: "",
                                is: "",
                                ci: "1")
        
        let shouldDowngraded = vac2Of1Biontech.downgrade2OutOf1ToBasisImmunization(otherCertificatesInTheUsersChain: [someBooster, vac1Of1JJ, vac2Of1Biontech],
                                                                                      recoveries: [])
        XCTAssertTrue(vac2Of1Biontech.isBoosted())
        XCTAssertFalse(shouldDowngraded)
    }
 
    func testDowngrade2OutOf2ToBasisImmunization() {
        let shouldDowngraded = vac2Of2Moderna.downgrade2OutOf1ToBasisImmunization(otherCertificatesInTheUsersChain: [vac1Of1JJ],
                                                                                      recoveries: nil)
        XCTAssertTrue(vac2Of1Biontech.isBoosted())
        XCTAssertTrue(shouldDowngraded)
    }
    
    func testDowngrade2OutOf2ToBasisImmunizationAndRecoveryAsOldest() {
        let recovery = Recovery(tg: "",
                                fr: Date() - 100,
                                df: Date(),
                                du: Date(),
                                co: "",
                                is: "",
                                ci: "3")
        
        let shouldDowngraded = vac2Of2Moderna.downgrade2OutOf1ToBasisImmunization(otherCertificatesInTheUsersChain: [vac1Of1JJ],
                                                                                      recoveries: [recovery])
        XCTAssertTrue(vac2Of1Biontech.isBoosted())
        XCTAssertFalse(shouldDowngraded)
    }
    
    func testDowngrade2OutOf2ToBasisImmunizationAndRecoveryAsNotOldest() {
        let recovery = Recovery(tg: "",
                                fr: Date() + 100,
                                df: Date(),
                                du: Date(),
                                co: "",
                                is: "",
                                ci: "3")
        
        let shouldDowngraded = vac2Of2Moderna.downgrade2OutOf1ToBasisImmunization(otherCertificatesInTheUsersChain: [vac1Of1JJ],
                                                                                      recoveries: [recovery])
        XCTAssertTrue(vac2Of1Biontech.isBoosted())
        XCTAssertTrue(shouldDowngraded)
    }
    
    func testDowngrade2OutOf2ToBasisImmunizationWithBoosterCert() {
        let someBooster = Vaccination(tg: "", vp: "",
                                mp: MedicalProduct.johnsonjohnson.rawValue,
                                ma: "",
                                dn: 3,
                                sd: 3,
                                dt: Date(),
                                co: "",
                                is: "",
                                ci: "1")
        
        let shouldDowngraded = vac2Of2Moderna.downgrade2OutOf1ToBasisImmunization(otherCertificatesInTheUsersChain: [someBooster, vac1Of1JJ, vac2Of1Biontech],
                                                                                      recoveries: [])
        XCTAssertTrue(vac2Of1Biontech.isBoosted())
        XCTAssertFalse(shouldDowngraded)
    }
 
    
    func testWalletApp_NotValidBecauseOfFresherThan14Days() throws {
        // GIVEN
        sut.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -10, to: Date()))
        sut.dn = 2
        sut.sd = 2
        sut.mp = MedicalProduct.biontech.rawValue
        // WHEN
        let result = sut.fullImmunizationValid
        // THEN
        XCTAssertFalse(result)
    }
    
    func testWalletApp_ValidBecauseOfFresherOlder14Days() throws {
        // GIVEN
        sut.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -15, to: Date()))
        sut.dn = 2
        sut.sd = 2
        sut.mp = MedicalProduct.biontech.rawValue
        // WHEN
        let result = sut.fullImmunizationValid
        // THEN
        XCTAssertTrue(result)
    }
    
    func testWalletApp_JJValidBecauseOfFresherOlder14Days() throws {
        // GIVEN
        sut.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -15, to: Date()))
        sut.dn = 2
        sut.sd = 2
        sut.mp = MedicalProduct.johnsonjohnson.rawValue
        // WHEN
        let result = sut.fullImmunizationValid
        
        XCTAssertTrue(result)
    }
}
