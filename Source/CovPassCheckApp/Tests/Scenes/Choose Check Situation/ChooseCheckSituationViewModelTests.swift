//
//  ChooseCheckSituationViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

final class ChooseCheckSituationViewModelTests: XCTestCase {
    
    var delegate: ViewModelDelegateMock!
    var promise: Promise<Void>!
    var resolver: Resolver<Void>!
    var router: ChooseCheckSituationRouterMock!
    var persistence: MockPersistence!
    var sut: ChooseCheckSituationViewModel!

    override func setUpWithError() throws {
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        self.resolver = resolver
        router = .init()
        delegate = .init()
        persistence = .init()
        configureSut()
        
    }
    private func configureSut() {
        sut = .init(router: router,
                    resolver: resolver,
                    persistence: persistence)
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        delegate = nil
        promise = nil
        resolver = nil
        router = nil
        sut = nil
    }
    
    func test_title() {
        XCTAssertEqual(sut.title, "How do you use the CovPassCheck app?")
    }
    
    func test_subtitle() {
        XCTAssertEqual(sut.subtitle, "Select on which basis the vaccination status is to be determined:")
    }
    
    func test_enteringGermanyImage() {
        XCTAssertEqual(sut.enteringGermanyImage, .checkboxUnchecked)
    }
    
    func test_withinGermanyImage() {
        XCTAssertEqual(sut.withinGermanyImage, .checkboxChecked)
    }
    
    func test_enteringGermanySubtitle() {
        XCTAssertEqual(sut.enteringGermanySubtitle, "On the basis of the Coronavirus Entry Regulations")
    }
    
    func test_enteringGermanyTitle() {
        XCTAssertEqual(sut.enteringGermanyTitle, "I check at entries")
    }
    
    func test_withinGermanySubtitle() {
        XCTAssertEqual(sut.withinGermanySubtitle, "On the basis of the Infection Protection Act §22a")
    }
    
    func test_withinGermanyTitle() {
        XCTAssertEqual(sut.withinGermanyTitle, "I check within Germany")
    }
    
    func test_closeAnnounce() {
        XCTAssertEqual(sut.closeAnnounce, #"The view "When do you use the CovPassCheck app?" has been closed."#)
    }
    
    func test_openAnnounce() {
        XCTAssertEqual(sut.openAnnounce, #"The view "When do you use the CovPassCheck app?" has been opened."#)
    }
    
    func test_hintText() {
        XCTAssertEqual(sut.hintText, "You can change this at any time in the settings.")
    }
    
    func test_hintImage() {
        XCTAssertEqual(sut.hintImage, .settings)
    }
    
    func test_buttonTitle() {
        XCTAssertEqual(sut.buttonTitle, "Apply")
    }
    
    func test_withinGermanyOptionAccessibiliyLabel() {
        XCTAssertEqual(sut.withinGermanyOptionAccessibiliyLabel, "Selected")
    }
    
    func test_enteringGermanyOptionAccessibiliyLabel() {
        XCTAssertEqual(sut.enteringGermanyOptionAccessibiliyLabel, "Not selected")
    }
    
    func test_withinGermanyOptionAccessibiliyLabel_enteringGermany() {
        sut.enteringGermanyViewIsChoosen()
        XCTAssertEqual(sut.withinGermanyOptionAccessibiliyLabel, "Not selected")
    }
    
    func test_enteringGermanyOptionAccessibiliyLabel_enteringGermany() {
        sut.enteringGermanyViewIsChoosen()
        XCTAssertEqual(sut.enteringGermanyOptionAccessibiliyLabel, "Selected")
    }
    
    func test_applyChanges() {
        // GIVEN
        let waitExpectation = XCTestExpectation(description: "waitExpectation")
        promise.done { sceneResult in
            waitExpectation.fulfill()
        }.catch { error in
            XCTFail("should not fail")
        }
        
        // WHEN
        sut.applyChanges()
        
        // THEN
        wait(for: [waitExpectation], timeout: 3)
    }
    
    func test_withinGermanyIsChoosen() {
        // WHEN
        sut.withinGermanyIsChoosen()
        sut.applyChanges()
        
        // THEN
        XCTAssertEqual(sut.withinGermanyImage, .checkboxChecked)
        XCTAssertEqual(sut.enteringGermanyImage, .checkboxUnchecked)
        XCTAssertEqual(persistence.checkSituation, CheckSituationType.withinGermany.rawValue)
    }
    
    func test_enteringGermanyViewIsChoosen() {
        // WHEN
        sut.enteringGermanyViewIsChoosen()
        sut.applyChanges()

        // THEN
        XCTAssertEqual(sut.withinGermanyImage, .checkboxUnchecked)
        XCTAssertEqual(sut.enteringGermanyImage, .checkboxChecked)
        XCTAssertEqual(persistence.checkSituation, CheckSituationType.enteringGermany.rawValue)
    }
}
