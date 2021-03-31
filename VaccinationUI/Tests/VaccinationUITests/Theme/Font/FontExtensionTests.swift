//
//  FontExtensionTests.swift
//  
//
//  Created by Daniel on 22.03.2021.
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
        try super.tearDownWithError()
        try UIFont.unloadCustomFonts()
    }

    // MARK: - Tests
    
    func testIbmPlexSansRegular() throws {
        XCTAssertNotNil(UIFont.ibmPlexSansRegular(with: 20))
    }
    
    func testIbmPlexSansSemiBold() throws {
        XCTAssertNotNil(UIFont.ibmPlexSansSemiBold(with: 20))
    }
}
