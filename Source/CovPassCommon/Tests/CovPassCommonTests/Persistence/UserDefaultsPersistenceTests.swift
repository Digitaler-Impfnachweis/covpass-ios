//
//  UserDefaultsPersistenceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class UserDefaultsPersistenceTests: XCTestCase {
    
    var sut: UserDefaultsPersistence!

    override func setUp() {
        super.setUp()
        sut = UserDefaultsPersistence()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testUserDefaultsPersistence() {
        let randomKey = "\(Date().timeIntervalSince1970.rounded())"
        XCTAssertNil(try sut.fetch(randomKey))
        XCTAssertNoThrow(try sut.store(randomKey, value: "1"))
        XCTAssertEqual(try sut.fetch(randomKey) as? String, "1")
        XCTAssertNoThrow(try sut.delete(randomKey))
        XCTAssertNil(try sut.fetch(randomKey))
    }
    
    func testSetLogicTypeEu() {
        // GIVEN
        sut.selectedLogicType = .eu
        // WHEN
        let selectedLogicType = sut.selectedLogicType
        // THEN
        XCTAssertEqual(selectedLogicType, .eu)
    }
    
    func testSetLogicTypeDe() {
        // GIVEN
        sut.selectedLogicType = .de
        // WHEN
        let selectedLogicType = sut.selectedLogicType
        // THEN
        XCTAssertEqual(selectedLogicType, .de)
    }
    
    func testSetLogicTypeBooster() {
        // GIVEN
        sut.selectedLogicType = .booster
        // WHEN
        let selectedLogicType = sut.selectedLogicType
        // THEN
        XCTAssertEqual(selectedLogicType, .booster)
    }
    
    func testSetRevocationExpertMode_True() {
        // GIVEN
        sut.revocationExpertMode = true
        // WHEN
        let revocationExpertMode = sut.revocationExpertMode
        // THEN
        XCTAssertEqual(revocationExpertMode, true)
    }
    
    func testSetRevocationExpertMode_False() {
        // GIVEN
        sut.revocationExpertMode = false
        // WHEN
        let revocationExpertMode = sut.revocationExpertMode
        // THEN
        XCTAssertEqual(revocationExpertMode, false)
    }
        
    func testSetRevocationExpertMode_Nil() throws {
        // GIVEN
        try sut.delete(UserDefaults.keyRevocationExpertMode)
        // WHEN
        let revocationExpertMode = sut.revocationExpertMode
        // THEN
        XCTAssertEqual(revocationExpertMode, false)
    }
}
