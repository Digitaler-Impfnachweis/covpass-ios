//
//  TopViewModifierTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import XCTest
import SwiftUI
@testable import VaccinationCommon

class TopViewModifierTests: XCTestCase {
    
    // MARK: - Test Variables
    
    var sut: TopViewModifier<Text>!
    var blurRadius: CGFloat = 20
    var destination = Text("Hello World")
    
    @State var isVisible: Bool = false
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = TopViewModifier(destination: destination, blurRadius: blurRadius, binding: $isVisible)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testBody() throws {
        XCTAssertNotNil(sut.body)
    }
    
    func testConfiguration() throws {
        XCTAssertEqual(sut.blurRadius, blurRadius)
        XCTAssertEqual(sut.destination, destination)
    }
    
    func testShowLoadingView() throws {
        XCTAssertNotNil(destination
            .showLoadingView(when: $isVisible) as? ModifiedContent<Text, TopViewModifier<LoadingView>>)
    }
    
    static var allTests = [
        ("testBody", testBody),
        ("testConfiguration", testConfiguration),
        ("testShowLoadingView", testShowLoadingView)
    ]
}
