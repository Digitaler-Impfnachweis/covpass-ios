//
//  FontExtensionTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import XCTest
@testable import VaccinationUI

class FontExtensionTests: XCTestCase {
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        try UIFont.loadCustomFonts()
    }
    
    override func tearDownWithError() throws {
        try UIFont.unloadCustomFonts()
        try super.tearDownWithError()
    }

    // MARK: - Tests
    
    func testIbmPlexSansRegular() throws {
        XCTAssertNotNil(UIFont.ibmPlexSansRegular(with: 20))
    }
    
    func testIbmPlexSansSemiBold() throws {
        XCTAssertNotNil(UIFont.ibmPlexSansSemiBold(with: 20))
    }
}
