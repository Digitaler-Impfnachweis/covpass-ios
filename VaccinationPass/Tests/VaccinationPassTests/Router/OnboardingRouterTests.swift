//
//  OnboardingRouterTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import XCTest
import VaccinationUI
@testable import VaccinationPass

final class OnboardingRouterTests: XCTestCase {
    
    // MARK: - Test Variables
    
    var sut: OnboardingRouter!
    var delegate: WindowDelegateMock!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = OnboardingRouter()
        delegate = WindowDelegateMock()
    }

    override func tearDown() {
        sut = nil
        delegate = nil 
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }
    
    func testNavigateToNextViewController() {
        sut.navigateToNextViewController()
        XCTAssertNotNil(delegate.updateCalled)
    }

    func testNavigateToPreviousViewController() {
        sut.navigateToPreviousViewController()
        XCTAssertNotNil(delegate.updateCalled)
    }
    
    func testRootViewControllerAction() {
        sut.windowDelegate = delegate
        XCTAssertNotNil(sut.windowDelegate)
    }
}
