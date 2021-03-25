//
//  LoadingViewTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//
import XCTest
import SwiftUI
@testable import VaccinationCommon

class LoadingViewTests: XCTestCase {
    
    // MARK: - Test Variables
    
    var sut: LoadingView!
    var size: CGFloat = 30
    var color: Color = .blue
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = LoadingView(dotSize: size, color: color)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testBody() throws {
        XCTAssertNotNil(sut.body is HStack<TupleView<(DotView, DotView, DotView)>>)
    }
    
    static var allTests = [
        ("testBody", testBody),
    ]
}
