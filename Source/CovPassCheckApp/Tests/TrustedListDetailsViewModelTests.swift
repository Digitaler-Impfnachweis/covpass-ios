//
//  TrustedListDetailsViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
@testable import CovPassCommon
import FBSnapshotTestCase
import XCTest

class TrustedListDetailsViewModelTests: XCTestCase {
    
    var sut: TrustedListDetailsViewModel!
    var vaccinationRepository: VaccinationRepositoryMock!
    var certLogic: DCCCertLogicMock!
    var delegate: ViewModelDelegateMock!
    
    override func setUp() {
        super.setUp()
        vaccinationRepository = VaccinationRepositoryMock()
        certLogic = DCCCertLogicMock()
        delegate = ViewModelDelegateMock()
        sut = TrustedListDetailsViewModel(repository: vaccinationRepository,
                                              certLogic: certLogic)
        sut.delegate = delegate
    }
    
    override func tearDown() {
        sut = nil
        vaccinationRepository = nil
        delegate = nil
        certLogic = nil
        super.tearDown()
    }
    
    func testPropertiesInitial() throws {
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.title)
        XCTAssertNil(sut.offlineMessageRules)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.offlineMessageCertificates)
        XCTAssertNotNil(sut.offlineModusButton)
        XCTAssertNotNil(sut.offlineModusInformation)
        XCTAssertNotNil(sut.offlineModusNoteUpdate)
    }
    
    func testPropertiesWithLastUpdate() throws {
        // Given
        certLogic.lastUpdateDccrRules = DateUtils.parseDate("2021-04-26T15:05:00")
        vaccinationRepository.lastUpdateTrustList = DateUtils.parseDate("2021-04-26T15:05:00")

        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.title)
        XCTAssertNotNil(sut.offlineMessageRules)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.offlineMessageCertificates)
        XCTAssertNotNil(sut.offlineModusButton)
        XCTAssertNotNil(sut.offlineModusInformation)
        XCTAssertNotNil(sut.offlineModusNoteUpdate)
    }
    
    func testRefresh() {
        // Given
        let exp1 = expectation(description: "didRefresh vaccinationRepository")
        let exp2 = expectation(description: "didRefresh certLogic")
        let exp3 = expectation(description: "didUpdate viewModel")
        vaccinationRepository.didUpdateTrustListHandler = { exp1.fulfill() }
        certLogic.didUpdateRules = { exp2.fulfill() }
        delegate.didUpdate = { exp3.fulfill() }
        
        // When
        sut.refresh()
        
        // Then
        XCTAssertTrue(sut.isLoading)
        wait(for: [exp1, exp2, exp3], timeout: 2, enforceOrder: true)
        XCTAssertFalse(sut.isLoading)
    }
    
}
