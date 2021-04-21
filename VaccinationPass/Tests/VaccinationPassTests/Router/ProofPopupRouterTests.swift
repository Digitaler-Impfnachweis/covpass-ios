//
//  ProofPopupRouterTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import XCTest
import VaccinationUI
@testable import VaccinationPass

final class ProofPopupRouterTests: XCTestCase {
    
    // MARK: - Test Variables
    
    var sut: ProofPopupRouter!
    var delegate: WindowDelegateMock!
    var popVC: UIViewController!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = ProofPopupRouter()
        delegate = WindowDelegateMock()
        popVC = UIViewController()
        
        // Load View
        let window = UIWindow(frame:  UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = popVC
    }
    
    override func tearDown() {
        sut = nil
        delegate = nil
        popVC = nil 
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }
    
    func testRootViewControllerNotNil() {
        XCTAssertNotNil(sut.presentPopup(onTopOf: popVC))
        let exp = expectation(description: "wait to present VC")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            exp.fulfill()
            XCTAssertNotNil(self.popVC.presentedViewController)
        }
        wait(for: [exp], timeout:  2)
    }
}
