//
//  DifferentPersonViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

 @testable import CovPassCheckApp
 import PromiseKit
 import XCTest

 class DifferentPersonViewModelTests: XCTestCase {
     private var delegate: ViewModelDelegateMock!
     private var sut: DifferentPersonViewModel!

     override func setUpWithError() throws {
         let (_, resolver) = Promise<DifferentPersonResult>.pending()
         delegate = .init()
         sut = .init(
             firstResultCert: .mockVaccinationCertificate,
             secondResultCert: .mockTestCertificate,
             resolver: resolver,
             countdownTimerModel: .init(dismissAfterSeconds: 0, countdownDuration: 0)
         )
         sut.delegate = delegate
     }

     override func tearDownWithError() throws {
         delegate = nil
         sut = nil
     }

     func testInit() {
         // Given
         let expectation = XCTestExpectation()
         delegate.didUpdate = {
             expectation.fulfill()
         }
         // Then
         wait(for: [expectation], timeout: 2)
         XCTAssertTrue(sut.countdownTimerModel.shouldDismiss)
     }
 }
