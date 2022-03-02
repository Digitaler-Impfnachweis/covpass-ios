//
//  CertificateDetailViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class CertificateDetailViewModelTests: XCTestCase {
    private var boosterLogic: BoosterLogicMock!
    private var sut: CertificateDetailViewModel!
    private var vaccinationRepo: VaccinationRepositoryMock!

    override func setUpWithError() throws {
        let certificates: [ExtendedCBORWebToken] = try [
            .token1Of2(),
            .token2Of2(),
            .token3Of3()
        ]
        configureCustomSut(certificates: certificates)
    }
    
    private func configureCustomSut(certificates: [ExtendedCBORWebToken]) {
        boosterLogic = BoosterLogicMock()
        vaccinationRepo = VaccinationRepositoryMock()
        sut = CertificateDetailViewModel(
            router: CertificateDetailRouterMock(),
            repository: vaccinationRepo,
            boosterLogic: boosterLogic,
            certificates: certificates,
            resolvable: nil
        )
    }
    
    private func configureSut(booosterState: BoosterCandidate.BoosterState) throws {
        let token3Of3 = try ExtendedCBORWebToken.token3Of3()
        var boosterCandidate = BoosterCandidate(certificate: token3Of3)
        boosterCandidate.state = booosterState
        let certificates: [ExtendedCBORWebToken] = try [
            .token1Of2(),
            .token2Of2(),
            token3Of3
        ]
        boosterLogic.boosterCandidates = [boosterCandidate]
        sut = CertificateDetailViewModel(
            router: CertificateDetailRouterMock(),
            repository: VaccinationRepositoryMock(),
            boosterLogic: boosterLogic,
            certificates: certificates,
            resolvable: nil
        )
    }

    override func tearDownWithError() throws {
        vaccinationRepo = nil
        boosterLogic = nil
        sut = nil
    }

    func testShowBoosterNotification_no_booster_candidate() {
        // When
        let showBoosterNotification = sut.showBoosterNotification

        // Then
        XCTAssertTrue(showBoosterNotification)
    }

    func testShowBoosterNotification_booster_candidate_state_none() throws {
        // Given
        try configureSut(booosterState: .none)

        // When
        let showBoosterNotification = sut.showBoosterNotification

        // Then
        XCTAssertFalse(showBoosterNotification)
    }

    func testShowBoosterNotification_booster_candidate_state_qualified() throws {
        // Given
        try configureSut(booosterState: .qualified)

        // When
        let showBoosterNotification = sut.showBoosterNotification

        // Then
        XCTAssertTrue(showBoosterNotification)
    }
    
    func testShowBoosterNotification_booster_candidate_state_new() throws {
        // Given
        try configureSut(booosterState: .new)

        // When
        let showBoosterNotification = sut.showBoosterNotification

        // Then
        XCTAssertTrue(showBoosterNotification)
    }
    
    func testStartReissue() throws {
        // When
        sut.triggerReissue()

        // Then
        let expectation1 = try XCTUnwrap((sut.router as? CertificateDetailRouterMock)?.expectationShowReissue)
        wait(for: [expectation1], timeout: 0.1)
    }
    
    func testShowReissueNotification_ReissueQualifiedCase1() throws {
        // GIVEN: 1/1 and 2/2 qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            .token1Of1(),
            .token2Of2(),
        ]
        configureCustomSut(certificates: certificates)
        
        // THEN
        XCTAssertTrue(sut.showReissueNotification)
    }
    
    func testShowReissueNotification_ReissueQualifiedCase2() throws {
        // GIVEN: 1/1 and 2/2 and recovery cert qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            CBORWebToken.mockRecoveryCertificate.extended(),
            .token1Of1(),
            .token2Of2(),
        ]
        configureCustomSut(certificates: certificates)
        
        // THEN
        XCTAssertTrue(sut.showReissueNotification)
    }
    
    func testNotShowReissueNotification_NotQualified() throws {
        // GIVEN: 2/2 doesnt qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            .token2Of2(),
        ]
        configureCustomSut(certificates: certificates)
        
        // THEN
        XCTAssertFalse(sut.showReissueNotification)
    }
    
    func testShowReissueNotification_WithNewBadge() throws {
        // GIVEN: 1/1 and 2/2 qualifies for reissue and set its already new seen property to false
        var certificates: [ExtendedCBORWebToken] = try [
            .token1Of1(),
            .token2Of2(),
        ]
        certificates[0].reissueProcessNewBadgeAlreadySeen = false
        certificates[1].reissueProcessNewBadgeAlreadySeen = false
        configureCustomSut(certificates: certificates)
        
        // THEN
        XCTAssertTrue(sut.reissueNew)
    }
    
    func testShowReissueNotification_WithoutNewBadge() throws {
        // GIVEN: 1/1 and 2/2 qualifies for reissue and set its already new seen property to true
        var certificates: [ExtendedCBORWebToken] = try [
            .token1Of1(),
            .token2Of2(),
        ]
        certificates[0].reissueProcessNewBadgeAlreadySeen = true
        certificates[1].reissueProcessNewBadgeAlreadySeen = true
        configureCustomSut(certificates: certificates)
        
        // THEN
        XCTAssertFalse(sut.reissueNew)
    }
    
    func testShowReissueNotification_WithoutNewBadge_alternative() throws {
        // GIVEN: 1/1 and 2/2 qualifies for reissue and set its already new seen property to true only on one cert should be enough
        var certificates: [ExtendedCBORWebToken] = try [
            .token1Of1(),
            .token2Of2(),
        ]
        certificates[0].reissueProcessNewBadgeAlreadySeen = true
        certificates[1].reissueProcessNewBadgeAlreadySeen = false
        configureCustomSut(certificates: certificates)
        
        // THEN
        XCTAssertFalse(sut.reissueNew)
    }
    
    func testUpdateReissueCandidate() throws {
        // GIVEN: 1/1 and 2/2 qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            .token1Of1(),
            .token2Of2(),
        ]
        configureCustomSut(certificates: certificates)

        // WHEN update reissues candidate it updates cert that they are already seen
        sut.updateReissueCandidate()
        // THEN
        wait(for: [vaccinationRepo.setReissueAlreadySeen], timeout: 1)
    }
}
