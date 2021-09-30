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
    
    var viewModel: ValidatorOverviewViewModel!
    
    override func setUp() {
        super.setUp()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let sceneCoordinator = DefaultSceneCoordinator(window: window)
        let repository = VaccinationRepository.create()
        self.viewModel = ValidatorOverviewViewModel(router: ValidatorOverviewRouter(sceneCoordinator: sceneCoordinator),
                                                    repository: repository,
                                                    certLogic:  DCCCertLogic.create())
    }
    
    func testInitDate() throws {
        let title: String = Localizer.localized("validation_start_screen_scan_sync_message_title", bundle: Bundle.main)
        XCTAssertNotNil(viewModel.ntpDate)
        XCTAssertNotNil(viewModel.ntpOffset)
        XCTAssertNotNil(viewModel.ntpDateFormatted)
        XCTAssertNotNil(viewModel.timeHintIcon)
        XCTAssertNotNil(viewModel.timeHintTitle)
        XCTAssertNotNil(viewModel.timeHintSubTitle)
        XCTAssertNotNil(viewModel.timeHintIsHidden)
        XCTAssert(viewModel.ntpOffset == 0.0)
        XCTAssert(viewModel.timeHintIcon == .warning)
        XCTAssert(viewModel.timeHintTitle == title)
        XCTAssert(viewModel.timeHintIsHidden == true)
    }
    
    func testNow() throws {
        let date = Date()
        viewModel.ntpDate = date
        viewModel.ntpOffset = 10
        let title: String = Localizer.localized("validation_start_screen_scan_sync_message_title", bundle: Bundle.main)
        let subTitle = Localizer.localized("validation_start_screen_scan_sync_message_text", bundle: Bundle.main)
            .replacingOccurrences(of: "%@",
                                  with: viewModel.ntpDateFormatted)
        XCTAssertNotNil(viewModel.ntpDate)
        XCTAssertNotNil(viewModel.ntpOffset)
        XCTAssertNotNil(viewModel.ntpDateFormatted)
        XCTAssertNotNil(viewModel.timeHintIcon)
        XCTAssertNotNil(viewModel.timeHintTitle)
        XCTAssertNotNil(viewModel.timeHintSubTitle)
        XCTAssertNotNil(viewModel.timeHintIsHidden)
        XCTAssert(viewModel.ntpDate == date)
        XCTAssert(viewModel.ntpOffset == 10.0)
        XCTAssert(viewModel.timeHintIcon == .warning)
        XCTAssert(viewModel.timeHintSubTitle == subTitle)
        XCTAssert(viewModel.timeHintTitle == title)
        XCTAssert(viewModel.timeHintIsHidden == true)
    }
    
    func testBeforeTwoHours() throws {
        let date = Date()
        viewModel.ntpDate = date
        viewModel.ntpOffset = -7200
        let title: String = Localizer.localized("validation_start_screen_scan_sync_message_title", bundle: Bundle.main)
        let subTitle = Localizer.localized("validation_start_screen_scan_sync_message_text", bundle: Bundle.main)
            .replacingOccurrences(of: "%@",
                                  with: viewModel.ntpDateFormatted)
        XCTAssertNotNil(viewModel.ntpDate)
        XCTAssertNotNil(viewModel.ntpOffset)
        XCTAssertNotNil(viewModel.ntpDateFormatted)
        XCTAssertNotNil(viewModel.timeHintIcon)
        XCTAssertNotNil(viewModel.timeHintTitle)
        XCTAssertNotNil(viewModel.timeHintSubTitle)
        XCTAssertNotNil(viewModel.timeHintIsHidden)
        XCTAssert(viewModel.ntpDate == date)
        XCTAssert(viewModel.ntpOffset == -7200)
        XCTAssert(viewModel.timeHintIcon == .warning)
        XCTAssert(viewModel.timeHintSubTitle == subTitle)
        XCTAssert(viewModel.timeHintTitle == title)
        XCTAssert(viewModel.timeHintIsHidden == false)
    }
    
    func testAfterTwoHours() throws {
        let date = Date()
        viewModel.ntpDate = date
        viewModel.ntpOffset = 7200
        let title: String = Localizer.localized("validation_start_screen_scan_sync_message_title", bundle: Bundle.main)
        let subTitle = Localizer.localized("validation_start_screen_scan_sync_message_text", bundle: Bundle.main)
            .replacingOccurrences(of: "%@",
                                  with: viewModel.ntpDateFormatted)
        XCTAssertNotNil(viewModel.ntpDate)
        XCTAssertNotNil(viewModel.ntpOffset)
        XCTAssertNotNil(viewModel.ntpDateFormatted)
        XCTAssertNotNil(viewModel.timeHintIcon)
        XCTAssertNotNil(viewModel.timeHintTitle)
        XCTAssertNotNil(viewModel.timeHintSubTitle)
        XCTAssertNotNil(viewModel.timeHintIsHidden)
        XCTAssert(viewModel.ntpDate == date)
        XCTAssert(viewModel.ntpOffset == 7200)
        XCTAssert(viewModel.timeHintIcon == .warning)
        XCTAssert(viewModel.timeHintSubTitle == subTitle)
        XCTAssert(viewModel.timeHintTitle == title)
        XCTAssert(viewModel.timeHintIsHidden == false)
    }
    
    func testAfterTwoHou2ewfrs() throws {
        for _ in 0...10 {
            let random = Double.random(in: 0...7200)
            viewModel.ntpOffset = random
            XCTAssert(viewModel.ntpOffset == random)
            XCTAssert(viewModel.timeHintIsHidden == true)
        }
    }
    
    func testAfterTwoHgfou2ewfrs() throws {
        for _ in 0...10 {
            let random = Double.random(in: 7201...20000)
            viewModel.ntpOffset = random
            XCTAssert(viewModel.ntpOffset == random)
            XCTAssert(viewModel.timeHintIsHidden == false)
        }
    }
    
}
