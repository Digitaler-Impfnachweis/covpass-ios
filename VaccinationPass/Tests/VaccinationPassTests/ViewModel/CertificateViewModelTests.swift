//
//  File.swift
//  
//
//  Created by Daniel on 19.04.2021.
//

import Foundation
import VaccinationUI
@testable import VaccinationPass


class CertificateViewModelTests: XCTestCase {
    
    // MARK: - Test Variables
    
    var sut: CertificateViewModel!

    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = CertificateViewModel()
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
        XCTAssertNotNil(sut.windowDelegate)
    }
}

