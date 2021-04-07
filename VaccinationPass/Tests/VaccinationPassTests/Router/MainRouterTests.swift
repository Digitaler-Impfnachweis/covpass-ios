//
//  MainRouterTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import XCTest
import VaccinationUI
@testable import VaccinationPass

final class MainRouterTests: XCTestCase {
    
    // MARK: - Test Variables
    
    var sut: MainRouter!
    var delegate: WindowDelegateMock!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = MainRouter()
        delegate = WindowDelegateMock()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }
    
    func testRootViewControllerNotNil() {
        XCTAssertNotNil(sut.rootViewController())
    }
    
    func testRootViewControllerAction() {
        sut.windowDelegate = delegate
        let vc = sut.rootViewController()
        vc.customToolbarView(CustomToolbarView(), didTap: ButtonItemType.textButton)
        XCTAssertTrue(delegate.updateCalled)
    }
}
