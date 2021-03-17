//
//  DotViewTests.swift
//  
//
//  Created by Daniel on 17.03.2021.
//

import XCTest
import SwiftUI
@testable import VaccinationCommon

class DotViewTests: XCTestCase {
    
    // MARK: - Test Variables
    
    var sut: DotView!
    var size: CGFloat = 30
    var color: Color = .blue
    var delay: Double = 0
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = DotView(size: size, delay: delay, color: color)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testConfiguration() throws {
        XCTAssertNotNil(sut.body)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(VaccinationCommon().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
