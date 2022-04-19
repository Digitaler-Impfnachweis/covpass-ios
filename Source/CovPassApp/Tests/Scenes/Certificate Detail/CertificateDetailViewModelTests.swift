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
    private var delegate: MockViewModelDelegate!
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
        delegate = .init()
        sut = CertificateDetailViewModel(
            router: CertificateDetailRouterMock(),
            repository: vaccinationRepo,
            boosterLogic: boosterLogic,
            certificates: certificates,
            resolvable: nil
        )
        sut.delegate = delegate
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
        delegate = nil
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
    
    func testShowReissueNotification_ReissueNotQualifiedCase_RecoveryIsYoungerThanVaccinations() throws {
        // GIVEN: 1/1 and 2/2 and recovery cert qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            CBORWebToken.mockRecoveryCertificate.extended(),
            .token1Of1(),
            .token2Of2(),
        ]
        configureCustomSut(certificates: certificates)
        
        // THEN
        XCTAssert(sut.showReissueNotification)
    }
    
    func testShowReissueNotification_ReissueQualifiedCase2() throws {
        // GIVEN: 1/1 and 2/2 and recovery cert qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            CBORWebToken.mockRecoveryCertificate.extended(),
            .token1Of1(),
            .token2Of2(),
        ]
        certificates[0].firstRecovery!.fr = Date().addingTimeInterval(-2000)
        certificates[1].firstVaccination!.dt = Date().addingTimeInterval(-1500)
        certificates[2].firstVaccination!.dt = Date().addingTimeInterval(-1000)
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
        sut.updateReissueCandidate(to: true)
        // THEN
        wait(for: [vaccinationRepo.setReissueAlreadySeen], timeout: 1)
    }

    func testName() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt())

        // When
        let name = sut.name

        // Then
        XCTAssertEqual(name, "Erika Mustermann")
    }

    private func tokensWithDifferentButMatchingFnt() throws -> [ExtendedCBORWebToken] {
        try [
            .token1Of2SchmidtMustermann(),
            .token2Of2Mustermann()
        ]
    }

    func testName_reversed_certificates() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt().reversed())

        // When
        let name = sut.name

        // Then
        XCTAssertEqual(name, "Erika Mustermann")
    }

    func testNameReversed() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt())

        // When
        let name = sut.nameReversed

        // Then
        XCTAssertEqual(name, "Mustermann, Erika")
    }

    func testNameReversed_reversed_certificates() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt().reversed())

        // When
        let name = sut.nameReversed

        // Then
        XCTAssertEqual(name, "Mustermann, Erika")
    }

    func testNameTransliterated() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt())

        // When
        let name = sut.nameTransliterated

        // Then
        XCTAssertEqual(name, "MUSTERMANN, ERIKA")
    }

    func testNameTransliterated_reversed_certificates() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt().reversed())

        // When
        let name = sut.nameTransliterated

        // Then
        XCTAssertEqual(name, "MUSTERMANN, ERIKA")
    }

    func testFavoriteIcon_default() {
        // When
        let favoriteIcon = sut.favoriteIcon

        // Then
        XCTAssertNil(favoriteIcon)
    }

    func testFavoriteIcon_certificates_of_one_person_which_is_favorite() {
        // Given
        vaccinationRepo.favoriteToggle = true
        sut.refresh()
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 2)

        // When
        let favoriteIcon = sut.favoriteIcon

        // Then
        XCTAssertNil(favoriteIcon)
    }

    func testFavoriteIcon_certificates_of_one_person_which_is_not_favorite() {
        // Given
        vaccinationRepo.favoriteToggle = false
        sut.refresh()
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 2)

        // When
        let favoriteIcon = sut.favoriteIcon

        // Then
        XCTAssertNil(favoriteIcon)
    }

    func testFavoriteIcon_certificates_of_two_persons_this_persons_is_favorite() throws {
        // Given
        vaccinationRepo.favoriteToggle = true
        vaccinationRepo.certificates = try [
            ExtendedCBORWebToken.token1Of1(),
            ExtendedCBORWebToken.token2Of2Pérez()
        ]
        sut.refresh()
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 2)

        // When
        let favoriteIcon = sut.favoriteIcon

        // Then
        XCTAssertEqual(favoriteIcon, UIImage.starFull)
    }

    func testFavoriteIcon_certificates_of_two_persons_this_person_is_not_favorite() throws {
        // Given
        vaccinationRepo.favoriteToggle = false
        vaccinationRepo.certificates = try [
            ExtendedCBORWebToken.token1Of1(),
            ExtendedCBORWebToken.token2Of2Pérez()
        ]
        sut.refresh()
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 2)

        // When
        let favoriteIcon = sut.favoriteIcon

        // Then
        XCTAssertEqual(favoriteIcon, UIImage.starPartial)
    }
}

private extension ExtendedCBORWebToken {
    static func token1Of2SchmidtMustermann() throws -> Self {
        try token(from: """
        {"1":"DE","4":1682239131,"6":1619167131,"-260":{"1":{"nam":{"gn":"Erika","fn":"Schmidt-Mustermann","gnt":"ERIKA","fnt":"SCHMIDT<MUSTERMANN"},"dob":"1964-08-12","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":1,"dt":"2021-02-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":2,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}}}
        """
        )
    }
    static func token2Of2Mustermann() throws -> Self {
        try token(from: """
        {"1":"DE","4":1682239131,"6":1619167131,"-260":{"1":{"nam":{"gn":"Erika","fn":"Mustermann","gnt":"ERIKA","fnt":"MUSTERMANN"},"dob":"1964-08-12","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":2,"dt":"2021-02-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":2,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}}}
        """
        )
    }

    static func token2Of2Pérez() throws -> Self {
        try token(from: """
        {"1":"DE","4":1682239131,"6":1619167131,"-260":{"1":{"nam":{"gn":"Juan","fn":"Pérez","gnt":"JUAN","fnt":"PEREZ"},"dob":"1964-08-12","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":2,"dt":"2021-02-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":2,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}}}
        """
        )
    }
}
