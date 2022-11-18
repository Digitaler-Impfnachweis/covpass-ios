//
//  Persistence+CheckSituationTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
import CovPassCommon

class PersistenceCheckSituationTests: XCTestCase {
 
    var sut: Persistence!
    
    override func setUpWithError() throws {
        sut = UserDefaultsPersistence()
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func test_checkSituation() {
        // GIVEN
        sut.checkSituation = 0
        
        // WHEN
        let checkSituation = sut.checkSituation
        
        // THEN
        XCTAssertEqual(checkSituation, sut.checkSituation)
    }
    
    func test_checkSituation_alternative() {
        // GIVEN
        sut.checkSituation = 1
        
        // WHEN
        let checkSituation = sut.checkSituation
        
        // THEN
        XCTAssertEqual(checkSituation, 1)
        XCTAssertEqual(sut.checkSituation, 1)
    }
}
