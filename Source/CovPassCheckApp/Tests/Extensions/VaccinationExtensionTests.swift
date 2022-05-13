//
//  VaccinationExtensionTests.swift
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
    var vac2Of1SomeProduct: Vaccination!
    
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
        vac2Of1SomeProduct = Vaccination(tg: "",
                                         vp: "",
                                         mp: MedicalProduct.biontech.rawValue,
                                         ma: "",
                                         dn: 2,
                                         sd: 1,
                                         dt: Date(),
                                         co: "",
                                         is: "",
                                         ci: "2")
    }
    
    override func tearDownWithError() throws {
        dtDate = nil
        sut = nil
        vac1Of1JJ = nil
        vac2Of1SomeProduct = nil
    }

    func testJohnsonJohnson1OutOf1() {
        // WHEN
        sut.mp = MedicalProduct.johnsonjohnson.rawValue
        sut.dn = 1
        sut.sd = 1
        
        // THEN
        XCTAssertFalse(sut.fullImmunization)
        XCTAssertTrue(sut.fullImmunizationCheck)
        XCTAssertFalse(sut.fullImmunizationValid)
        XCTAssertFalse(sut.isFullImmunizationAfterRecovery)
        XCTAssertFalse(sut.isBoosted())
        XCTAssertEqual(sut.fullImmunizationValidFrom, nil)
    }
    
    func testJohnsonJohnson3OutOf1() {
        // WHEN
        sut.mp = MedicalProduct.johnsonjohnson.rawValue
        sut.dn = 3
        sut.sd = 1
        
        // THEN
        XCTAssertTrue(sut.fullImmunization)
        XCTAssertTrue(sut.fullImmunizationCheck)
        XCTAssertTrue(sut.fullImmunizationValid)
        XCTAssertFalse(sut.isFullImmunizationAfterRecovery)
        XCTAssertTrue(sut.isBoosted())
        XCTAssertEqual(sut.fullImmunizationValidFrom, dtDate)
    }
    
    func testCheckApp_NotValidBecauseOfFresherThan14Days() throws {
        // GIVEN
        sut.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -10, to: Date()))
        sut.dn = 2
        sut.sd = 2
        sut.mp = MedicalProduct.biontech.rawValue
        // WHEN
        let result = sut.fullImmunizationValidCheckApp
        // THEN
        XCTAssertFalse(result)
    }
    
    func testCheckApp_ValidBecauseOfFresherOlder14Days() throws {
        // GIVEN
        sut.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -15, to: Date()))
        sut.dn = 2
        sut.sd = 2
        sut.mp = MedicalProduct.biontech.rawValue
        // WHEN
        let result = sut.fullImmunizationValidCheckApp
        // THEN
        XCTAssertTrue(result)
    }
    
    func testCheckApp_JJValidBecauseOfFresherOlder14Days() throws {
        // GIVEN
        sut.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -15, to: Date()))
        sut.dn = 2
        sut.sd = 2
        sut.mp = MedicalProduct.johnsonjohnson.rawValue
        // WHEN
        let result = sut.fullImmunizationValidCheckApp
        // THEN
        XCTAssertTrue(result)
    }
    
}
