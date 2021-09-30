//
//  ValidatorOverviewViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
@testable import CovPassCommon
@testable import CovPassUI
import XCTest

class ValidatorOverviewViewModelTests: XCTestCase {
    
    var sut: ValidatorOverviewViewModel!
    
    override func setUp() {
        super.setUp()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let sceneCoordinator = DefaultSceneCoordinator(window: window)
        let repository = VaccinationRepository.create()
        sut = ValidatorOverviewViewModel(router: ValidatorOverviewRouter(sceneCoordinator: sceneCoordinator),
                                               repository: repository,
                                               certLogic:  DCCCertLogic.create())
    }
    
    func testInitDate() throws {
        let title: String = Localizer.localized("validation_start_screen_scan_sync_message_title", bundle: Bundle.main)
        XCTAssert(sut.ntpOffset == 0.0)
        XCTAssert(sut.timeHintIcon == .warning)
        XCTAssert(sut.timeHintTitle == title)
        XCTAssert(sut.timeHintIsHidden == true)
    }
    
    func testNow() throws {
        let date = Date()
        sut.ntpDate = date
        sut.ntpOffset = 10
        let title: String = Localizer.localized("validation_start_screen_scan_sync_message_title", bundle: Bundle.main)
        let subTitle = Localizer.localized("validation_start_screen_scan_sync_message_text", bundle: Bundle.main)
            .replacingOccurrences(of: "%@",
                                  with: sut.ntpDateFormatted)
        XCTAssert(sut.ntpDate == date)
        XCTAssert(sut.ntpOffset == 10.0)
        XCTAssert(sut.timeHintIcon == .warning)
        XCTAssert(sut.timeHintSubTitle == subTitle)
        XCTAssert(sut.timeHintTitle == title)
        XCTAssert(sut.timeHintIsHidden == true)
    }
    
    func testBeforeTwoHours() throws {
        let date = Date()
        sut.ntpDate = date
        sut.ntpOffset = -7200
        let title: String = Localizer.localized("validation_start_screen_scan_sync_message_title", bundle: Bundle.main)
        let subTitle = Localizer.localized("validation_start_screen_scan_sync_message_text", bundle: Bundle.main)
            .replacingOccurrences(of: "%@",
                                  with: sut.ntpDateFormatted)
        XCTAssert(sut.ntpDate == date)
        XCTAssert(sut.ntpOffset == -7200)
        XCTAssert(sut.timeHintIcon == .warning)
        XCTAssert(sut.timeHintSubTitle == subTitle)
        XCTAssert(sut.timeHintTitle == title)
        XCTAssert(sut.timeHintIsHidden == false)
    }
    
    func testAfterTwoHours() throws {
        let date = Date()
        sut.ntpDate = date
        sut.ntpOffset = 7200
        let title: String = Localizer.localized("validation_start_screen_scan_sync_message_title", bundle: Bundle.main)
        let subTitle = Localizer.localized("validation_start_screen_scan_sync_message_text", bundle: Bundle.main)
            .replacingOccurrences(of: "%@",
                                  with: sut.ntpDateFormatted)
        XCTAssert(sut.ntpDate == date)
        XCTAssert(sut.ntpOffset == 7200)
        XCTAssert(sut.timeHintIcon == .warning)
        XCTAssert(sut.timeHintSubTitle == subTitle)
        XCTAssert(sut.timeHintTitle == title)
        XCTAssert(sut.timeHintIsHidden == false)
    }
    
    func testRandomOffsetsWhereHintShouldBeHidden() throws {
        for _ in 0...10 {
            let random = Double.random(in: 0...7199)
            sut.ntpOffset = random
            XCTAssert(sut.ntpOffset == random)
            XCTAssert(sut.timeHintIsHidden == true)
        }
    }
    
    func testRandomOffsetsWhereHintShouldBeNotHidden() throws {
        for _ in 0...10 {
            let random = Double.random(in: 7200...20000)
            sut.ntpOffset = random
            XCTAssert(sut.ntpOffset == random)
            XCTAssert(sut.timeHintIsHidden == false)
        }
    }
    
    func testRandomOffsetsWhereHintShouldBeHiddenPast() throws {
        for _ in 0...10 {
            let random = Double.random(in: -7199 ... -0)
            sut.ntpOffset = random
            XCTAssert(sut.ntpOffset == random)
            XCTAssert(sut.timeHintIsHidden == true)
        }
    }
    
    func testRandomOffsetsWhereHintShouldBeNotHiddenPast() throws {
        for _ in 0...10 {
            let random = Double.random(in: -20000 ... -7200)
            sut.ntpOffset = random
            XCTAssert(sut.ntpOffset == random)
            XCTAssert(sut.timeHintIsHidden == false)
        }
    }
    
}
