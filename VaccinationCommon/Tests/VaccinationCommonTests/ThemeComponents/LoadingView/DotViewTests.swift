//
//  DotViewTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
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
    
    func testBody() throws {
        XCTAssertNotNil(sut.body)
    }

    static var allTests = [
        ("testBody", testBody),
    ]
}
