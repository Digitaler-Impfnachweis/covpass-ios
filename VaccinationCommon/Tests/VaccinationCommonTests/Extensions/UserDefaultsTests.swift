//
//  File.swift
//  
//
//  Created by Timo Koenig on 15.04.21.
//

import Foundation
import XCTest

@testable import VaccinationCommon

class UserDefaultsTests: XCTestCase {

    override class func tearDown() {
        UserDefaults.StartupInfo.remove(.onboarding)
        super.tearDown()
    }
    
    func testStartupOnboardingNotSet() {
        let sut = UserDefaults.StartupInfo.bool(.onboarding)
        XCTAssertEqual(sut, false)
    }
    
    func testStartupOnboardingTrue() {
        UserDefaults.StartupInfo.set(true, forKey: .onboarding)
        let sut = UserDefaults.StartupInfo.bool(.onboarding)
        XCTAssertEqual(sut, true)
    }
    
    func testStartupOnboardingFalse() {
        UserDefaults.StartupInfo.set(false, forKey: .onboarding)
        let sut = UserDefaults.StartupInfo.bool(.onboarding)
        XCTAssertEqual(sut, false)
    }
}
