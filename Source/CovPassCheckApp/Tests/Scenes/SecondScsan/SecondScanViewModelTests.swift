//
//  SecondScanViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

final class SecondScanViewModelTests: XCTestCase {
    
    var countdownTimerModel: CountdownTimerModel!
    var delegate: ViewModelDelegateMock!
    var promise: Promise<ValidatorDetailSceneResult>!
    var resolver: Resolver<ValidatorDetailSceneResult>!
    var router: CertificateInvalidResultRouterMock!
    var sut: SecondScanViewModel!

    override func setUpWithError() throws {
        let (promise, resolver) = Promise<ValidatorDetailSceneResult>.pending()
        countdownTimerModel = .init(dismissAfterSeconds: 100, countdownDuration: 0)
        self.promise = promise
        self.resolver = resolver
        router = .init()
        delegate = .init()
        configureSut()
        
    }
    private func configureSut(secondToken: ExtendedCBORWebToken? = nil) {
        sut = .init(resolver: resolver,
                    token: CBORWebToken.mockVaccinationCertificate.extended(),
                    secondToken: secondToken,
                    countdownTimerModel: countdownTimerModel)
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        countdownTimerModel = nil
        delegate = nil
        promise = nil
        resolver = nil
        router = nil
        sut = nil
    }
    
    func test_nextButtonTitle() {
        XCTAssertEqual(sut.scanNextButtonTitle, "Scan another certificate")
    }
    
    func test_startOverButtonTitle() {
        XCTAssertEqual(sut.startOverButtonTitle, "New scan")
    }
    
    func test_thirdScanViewIsHidden() {
        XCTAssertEqual(sut.thirdScanViewIsHidden, true)
    }
    
    func test_thirdScanViewIsHidden_false() {
        configureSut(secondToken: CBORWebToken.mockRecoveryCertificate.extended())
        XCTAssertEqual(sut.thirdScanViewIsHidden, false)
    }
    
    func test_hintSubtitle() {
        XCTAssertEqual(sut.hintSubtitle, "Multiple vaccination proofs are required to confirm complete vaccination protection.")
    }
    
    func test_hintTitle() {
        XCTAssertEqual(sut.hintTitle, "Please note")
    }
    
    func test_subtitle() {
        XCTAssertEqual(sut.subtitle, "according to IfSG §22a")
    }
    
    func test_title() {
        XCTAssertEqual(sut.title, "Check vaccination status")
    }
    
    func test_firstScanIcon() {
        XCTAssertEqual(sut.firstScanIcon, .statusPartialCircle)
    }
    
    func test_firstScanTitle() {
        XCTAssertEqual(sut.firstScanTitle, "1st certificate")
    }
    
    func test_firstScanSubtitle() {
        XCTAssertEqual(sut.firstScanSubtitle, "Insufficient")
    }
    
    func test_secondScanIcon() {
        XCTAssertEqual(sut.secondScanIcon, .cardEmpty)
    }
    
    func test_secondScanIcon_isThirdScan() {
        configureSut(secondToken: CBORWebToken.mockRecoveryCertificate.extended())
        XCTAssertEqual(sut.secondScanIcon, .statusPartialCircle)
    }

    func test_secondScanTitle() {
        XCTAssertEqual(sut.secondScanTitle, "2nd certificate")
    }
    
    func test_secondScanSubtitle() {
        XCTAssertEqual(sut.secondScanSubtitle, "Please scan another proof of vaccination")
    }
    
    func test_thirdScanIcon() {
        XCTAssertEqual(sut.thirdScanIcon, .cardEmpty)
    }
    
    func test_thirdScanTitle() {
        XCTAssertEqual(sut.thirdScanTitle, "3rd certificate")
    }
    
    func test_thirdScanSubtitle() {
        XCTAssertEqual(sut.thirdScanSubtitle, "Please scan another proof of vaccination")
    }
    
    func test_cancel() {
        // GIVEN
        let waitExpectation = XCTestExpectation(description: "waitExpectation")
        promise.done { sceneResult in
            XCTAssertEqual(sceneResult, .close)
            waitExpectation.fulfill()
        }.catch { error in
            XCTFail("should not fail")
        }
        
        // WHEN
        sut.cancel()
        
        // THEN
        wait(for: [waitExpectation], timeout: 3)
    }
    
    func test_startOver() {
        // GIVEN
        let waitExpectation = XCTestExpectation(description: "waitExpectation")
        promise.done { sceneResult in
            XCTAssertEqual(sceneResult, .startOver)
            waitExpectation.fulfill()
        }.catch { error in
            XCTFail("should not fail")
        }
        
        // WHEN
        sut.startOver()
        
        // THEN
        wait(for: [waitExpectation], timeout: 3)
    }
    
    func test_scanNext() {
        // GIVEN
        let waitExpectation = XCTestExpectation(description: "waitExpectation")
        promise.done { sceneResult in
            XCTAssertEqual(sceneResult, .secondScan(CBORWebToken.mockVaccinationCertificate.extended()))
            waitExpectation.fulfill()
        }.catch { error in
            XCTFail("should not fail")
        }
        
        // WHEN
        sut.scanNext()
        
        // THEN
        wait(for: [waitExpectation], timeout: 3)
    }
    
    func test_countdownTimerModel() {
        // Given
        let didUpdateExpectation = XCTestExpectation(description: "didUpdateExpectation")
        let doneExpectation = XCTestExpectation(description: "doneExpectation")
        countdownTimerModel = .init(dismissAfterSeconds: 1.5, countdownDuration: 1)
        delegate.didUpdate = { didUpdateExpectation.fulfill() }
        promise.done { result in doneExpectation.fulfill() }.cauterize()

        // When
        configureSut()

        // Then
        wait(for: [didUpdateExpectation, doneExpectation], timeout: 3, enforceOrder: true)
    }
}
