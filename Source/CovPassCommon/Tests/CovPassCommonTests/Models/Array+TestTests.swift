//
//  Array+TestTests.swift
//  
//
//  Created by Fatih Karakurt on 13.09.22.
//

@testable import CovPassCommon

import Foundation
import XCTest

class ArrayTestTests: XCTestCase {
    
    var sut: [Test]!
    
    override func setUpWithError() throws {
        sut = [Test(tg: "", tt: "", sc: Date(), tr: "", tc: "", co: "", is: "", ci: "1"),
               Test(tg: "", tt: "", sc: Date() - 100, tr: "", tc: "", co: "", is: "", ci: "2"),
               Test(tg: "", tt: "", sc: Date() - 1000, tr: "", tc: "", co: "", is: "", ci: "3"),
               Test(tg: "", tt: "", sc: Date() + 1000, tr: "", tc: "", co: "", is: "", ci: "4"),
               Test(tg: "", tt: "", sc: Date() + 100, tr: "", tc: "", co: "", is: "", ci: "5")]
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testLatestVaccination() {
        // WHEN
        let latestTest = sut.latestTest
        
        // THEN
        XCTAssertEqual(latestTest?.ci, "4")
    }
}
