//
//  CertificateDetailViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class CertificateDetailViewModelTests: XCTestCase {
    private var boosterLogic: BoosterLogicMock!
    private var certificateHolderStatusModel: CertificateHolderStatusModelMock!
    private var delegate: MockViewModelDelegate!
    private var promise: Promise<CertificateDetailSceneResult>!
    private var resolver: Resolver<CertificateDetailSceneResult>!
    private var router: CertificateDetailRouterMock!
    private var sut: CertificateDetailViewModel!
    private var vaccinationRepo: VaccinationRepositoryMock!

    override func setUpWithError() throws {
        let certificates: [ExtendedCBORWebToken] = try [
            .token1Of2(),
            .token2Of2(),
            .token3Of3()
        ]
        let (promise, resolver) = Promise<CertificateDetailSceneResult>.pending()
        self.promise = promise
        self.resolver = resolver
        router = .init()
        certificateHolderStatusModel = .init()
        configureCustomSut(certificates: certificates)
    }
    
    private func configureCustomSut(certificates: [ExtendedCBORWebToken]) {
        boosterLogic = BoosterLogicMock()
        vaccinationRepo = VaccinationRepositoryMock()
        delegate = .init()
        sut = CertificateDetailViewModel(
            router: router,
            repository: vaccinationRepo,
            boosterLogic: boosterLogic,
            certificates: certificates,
            resolvable: resolver,
            certificateHolderStatusModel: certificateHolderStatusModel
        )
        sut.delegate = delegate
    }
    
    private func configureSut(booosterState: BoosterCandidate.BoosterState = .none) throws {
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
            router: router,
            repository: VaccinationRepositoryMock(),
            boosterLogic: boosterLogic,
            certificates: certificates,
            resolvable: resolver,
            certificateHolderStatusModel: certificateHolderStatusModel
        )
    }

    override func tearDownWithError() throws {
        vaccinationRepo = nil
        boosterLogic = nil
        delegate = nil
        promise = nil
        router = nil
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
        sut.triggerBoosterReissue()

        // Then
        wait(for: [router.expectationShowReissue], timeout: 0.1)
    }
    
    func testShowReissueNotification_ReissueQualifiedCase1() throws {
        // GIVEN: 1/1 and 2/2 qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            .token1Of1(),
            .token2Of2(),
        ]
        configureCustomSut(certificates: certificates)
        
        // THEN
        XCTAssertTrue(sut.showBoosterReissueNotification)
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
        XCTAssert(sut.showBoosterReissueNotification)
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
        XCTAssertTrue(sut.showBoosterReissueNotification)
    }
    
    func testNotShowReissueNotification_NotQualified() throws {
        // GIVEN: 2/2 doesnt qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            .token2Of2(),
        ]
        configureCustomSut(certificates: certificates)
        
        // THEN
        XCTAssertFalse(sut.showBoosterReissueNotification)
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
        XCTAssertTrue(sut.showBoosterReissueIsNewBadge)
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
        XCTAssertFalse(sut.showBoosterReissueIsNewBadge)
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
        XCTAssertFalse(sut.showBoosterReissueIsNewBadge)
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

    func testImmunizationButton_neither_revoked_nor_invalid() {
        // Given
        sut.refresh()

        // When
        let immunizationButton = sut.immunizationButton

        // Then
        XCTAssertEqual(immunizationButton, "Show certificates")
    }

    func testImmunizationButton_revoked() throws {
        // Given
        try configureSut(revoked: true)

        // When
        let immunizationButton = sut.immunizationButton

        // Then
        XCTAssertEqual(immunizationButton, "Add new certificate")
    }

    private func configureSut(invalid: Bool? = nil, revoked: Bool? = nil) throws {
        var token = try ExtendedCBORWebToken.token1Of1()
        token.revoked = revoked
        token.invalid = invalid
        configureCustomSut(certificates: [token])
    }

    func testImmunizationButton_invalid() throws {
        // Given
        try configureSut(invalid: true)

        // When
        let immunizationButton = sut.immunizationButton

        // Then
        XCTAssertEqual(immunizationButton, "Add new certificate")
    }

    func testImmunizationIcon_revoked() throws {
        // Given
        try configureSut(revoked: true)

        // When
        let immunizationIcon = sut.immunizationIcon

        // Then
        XCTAssertEqual(immunizationIcon, .statusExpiredCircle)
    }

    func testImmunizationIcon_invalid() throws {
        // Given
        try configureSut(invalid: true)

        // When
        let immunizationIcon = sut.immunizationIcon

        // Then
        XCTAssertEqual(immunizationIcon, .statusExpiredCircle)
    }

    func testImmunizationTitle_revoked() throws {
        // Given
        try configureSut(revoked: true)

        // When
        let immunizationTitle = sut.immunizationTitle

        // Then
        XCTAssertEqual(immunizationTitle, "Certificate invalid")
    }

    func testImmunizationTitle_invalid() throws {
        // Given
        try configureSut(invalid: true)

        // When
        let immunizationTitle = sut.immunizationTitle

        // Then
        XCTAssertEqual(immunizationTitle, "Certificate invalid")
    }

    func testImmunizationTitle_vaccination() {
        // Given
        let token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(2)
            .seriesOfDoses(2)
            .medicalProduct(.johnsonjohnson)
            .extended()
        configureCustomSut(certificates: [token])

        // When
        let immunizationTitle = sut.immunizationTitle

        // Then
        XCTAssertEqual(immunizationTitle, "Vaccine dose 2 of 2")
    }

    func testImmunizationBody_revoked_vaccination_certificate_german_issuer() throws {
        // Given
        try configureSut(revoked: true)

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The RKI has revoked the certificate due to an official decree.")
    }

    func testImmunizationBody_revoked_vaccination_certificate_non_german_issuer() throws {
        // Given
        var token = try ExtendedCBORWebToken.token1Of1()
        token.vaccinationCertificate.iss = "XL"
        token.revoked = true
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The certificate was revoked by the certificate issuer due to an official decision.")
    }

    func testImmunizationBody_revoked_test_certificate_german_issuer() {
        // Given
        var token = CBORWebToken.mockTestCertificate.extended()
        token.revoked = true
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The RKI has revoked the certificate due to an official decree.")
    }

    func testImmunizationBody_revoked_test_certificate_non_german_issuer() throws {
        // Given
        var token = CBORWebToken.mockTestCertificate.extended()
        token.vaccinationCertificate.iss = "XL"
        token.revoked = true
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The certificate was revoked by the certificate issuer due to an official decision.")
    }

    func testImmunizationBody_revoked_recovery_certificate_german_issuer() {
        // Given
        var token = CBORWebToken.mockRecoveryCertificate.extended()
        token.revoked = true
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The RKI has revoked the certificate due to an official decree.")
    }

    func testImmunizationBody_revoked_recovery_certificate_non_german_issuer() throws {
        // Given
        var token = CBORWebToken.mockRecoveryCertificate.extended()
        token.vaccinationCertificate.iss = "XL"
        token.revoked = true
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The certificate was revoked by the certificate issuer due to an official decision.")
    }

    func testImmunizationBody_expired_certificate_non_german_issuer() throws {
        // Given
        var token = CBORWebToken.mockRecoveryCertificate.extended()
        token.vaccinationCertificate.iss = "XL"
        token.vaccinationCertificate.exp = .init(timeIntervalSinceReferenceDate: 0)
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(
            immunizationBody,
            "Your latest certificate was not issued in Germany and therefore cannot be renewed in the app. Please contact the issuer of the certificate."
        )
    }

    func testImmunizationBody_expiring_soon_certificate_non_german_issuer() throws {
        // Given
        var token = CBORWebToken.mockRecoveryCertificate.extended()
        token.vaccinationCertificate.iss = "XL"
        token.vaccinationCertificate.exp = .init(timeIntervalSinceNow: 1000)
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(
            immunizationBody,
            "Your latest certificate was not issued in Germany and therefore cannot be renewed in the app. Please contact the issuer of the certificate."
        )
    }

    func testImmunizationBody_expired_certificate_german_issuer() throws {
        // Given
        var token = CBORWebToken.mockRecoveryCertificate.extended()
        token.vaccinationCertificate.exp = .init(timeIntervalSinceReferenceDate: 0)
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(
            immunizationBody,
            "The expiry date of your latest certificate has passed. You can conveniently renew this certificate in the CovPass app. Previous certificates will not be renewed. To do so, use the renewal function in the overview of your certificates or scan a newly issued certificate."
        )
    }

    func testShowScanHint_revoked() throws {
        // Given
        try configureSut(revoked: true)

        // When
        let showScanHint = sut.showScanHint

        // Then
        XCTAssertFalse(showScanHint)
    }

    func testShowScanHint_not_revoked() throws {
        // Given
        try configureSut()

        // When
        let showScanHint = sut.showScanHint

        // Then
        XCTAssertTrue(showScanHint)
    }

    func testImmunizationButtonTapped_certificate_invalid() throws {
        // Given
        try configureSut(invalid: true)
        let expectation = XCTestExpectation()
        promise
            .done { result in
                switch result {
                case .addNewCertificate:
                    expectation.fulfill()
                default:
                    break
                }
            }
            .cauterize()

        // When
        sut.immunizationButtonTapped()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testImmunizationButtonTapped_certificate_revoked() throws {
        // Given
        try configureSut(revoked: true)
        let expectation = XCTestExpectation()
        promise
            .done { result in
                switch result {
                case .addNewCertificate:
                    expectation.fulfill()
                default:
                    break
                }
            }
            .cauterize()

        // When
        sut.immunizationButtonTapped()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testImmunizationButtonTapped_valid_certificate() throws {
        // Given
        try configureSut()
        let expectation = XCTestExpectation()
        promise
            .done { result in
                switch result {
                case .showCertificatesOnOverview:
                    expectation.fulfill()
                default:
                    break
                }
            }
            .cauterize()

        // When
        sut.immunizationButtonTapped()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testShowVaccinationExpiryReissueNotification_no_reissueble_vaccination() throws {
        // Given
        configureCustomSut(certificates: [.nonReissuableVaccination])

        // When
        let showVaccinationExpiryReissueNotification = sut.showVaccinationExpiryReissueNotification

        // Then
        XCTAssertFalse(showVaccinationExpiryReissueNotification)
    }

    func testShowVaccinationExpiryReissueNotification_reissueble_vaccination() throws {
        // Given
        configureCustomSut(certificates: [.reissuableVaccination])

        // When
        let showVaccinationExpiryReissueNotification = sut.showVaccinationExpiryReissueNotification

        // Then
        XCTAssertTrue(showVaccinationExpiryReissueNotification)
    }

    func testShowVaccinationExpiryReissueIsNewBadge_is_new() {
        // Given
        let token = ExtendedCBORWebToken.reissuableVaccination
        configureCustomSut(certificates: [token])

        // When
        let showVaccinationExpiryReissueIsNewBadge = sut.showVaccinationExpiryReissueIsNewBadge

        // Then
        XCTAssertTrue(showVaccinationExpiryReissueIsNewBadge)
    }

    func testShowVaccinationExpiryReissueIsNewBadge_is_not_new() {
        // Given
        var token = ExtendedCBORWebToken.reissuableVaccination
        token.reissueProcessNewBadgeAlreadySeen = true
        configureCustomSut(certificates: [token])

        // When
        let showVaccinationExpiryReissueIsNewBadge = sut.showVaccinationExpiryReissueIsNewBadge

        // Then
        XCTAssertFalse(showVaccinationExpiryReissueIsNewBadge)
    }
    
    func testShowRecoveryExpiryReissueIsNewBadge_is_new() {
        // Given
        var token = ExtendedCBORWebToken.reissuableRecovery
        token.reissueProcessNewBadgeAlreadySeen = false
        configureCustomSut(certificates: [token])

        // When
        let showRecoveryExpiryReissueIsNewBadge = sut.showRecoveryExpiryReissueIsNewBadge(index: 0)

        // Then
        XCTAssertTrue(showRecoveryExpiryReissueIsNewBadge)
    }
    
    func testShowRecoveryExpiryReissueIsNewBadge_is_new_with_nil() {
        // Given
        var token = ExtendedCBORWebToken.reissuableRecovery
        token.reissueProcessNewBadgeAlreadySeen = nil
        configureCustomSut(certificates: [token])

        // When
        let showRecoveryExpiryReissueIsNewBadge = sut.showRecoveryExpiryReissueIsNewBadge(index: 0)

        // Then
        XCTAssertTrue(showRecoveryExpiryReissueIsNewBadge)
    }

    func testShowRecoveryExpiryReissueIsNewBadge_is_not_new() {
        // Given
        var token = ExtendedCBORWebToken.reissuableRecovery
        token.reissueProcessNewBadgeAlreadySeen = true
        configureCustomSut(certificates: [token])

        // When
        let showRecoveryExpiryReissueIsNewBadge = sut.showRecoveryExpiryReissueIsNewBadge(index: 0)

        // Then
        XCTAssertFalse(showRecoveryExpiryReissueIsNewBadge)
    }

    func testTriggerVaccinationExpiryReissue() {
        // Given
        let token1 = ExtendedCBORWebToken.reissuableVaccination
        let token2 = ExtendedCBORWebToken.reissuableVaccination
        configureCustomSut(
            certificates: [
                token1,
                token2,
                .reissuableRecovery,
                .reissuableRecovery,
            ]
        )
        
        // When
        sut.triggerVaccinationExpiryReissue()
        
        // Then
        wait(for: [
            router.expectationShowReissue,
            vaccinationRepo.getCertificateListExpectation,
            delegate.viewModelDidUpdateExpectation
        ], timeout: 1)
        let tokens = router.receivedReissueTokens
        XCTAssertEqual(tokens.count, 1)
    }

    func testTriggerRecoveryExpiryReissue() throws {
        // Given
        let token1 = ExtendedCBORWebToken.reissuableRecovery
        let token2 = ExtendedCBORWebToken.reissuableRecovery
        try configureCustomSut(
            certificates: [
                token1,
                token2,
                .reissuableVaccination,
                .reissuableVaccination,
                .token2Of2()
            ]
        )

        // When
        sut.triggerRecoveryExpiryReissue(index: 0)

        // Then
        wait(for: [
            router.expectationShowReissue,
            vaccinationRepo.getCertificateListExpectation,
            delegate.viewModelDidUpdateExpectation
        ], timeout: 1)
        let tokens = router.receivedReissueTokens
        XCTAssertEqual(tokens.count, 3)
    }

    func testMarkExpiryReissueCandidatesAsSeen() {
        // Given
        vaccinationRepo.replaceExpectation.expectedFulfillmentCount = 3
        configureCustomSut(
            certificates: [
                .reissuableRecovery,
                .reissuableRecovery,
                .reissuableVaccination,
                .reissuableVaccination,
                .nonReissuableVaccination
            ]
        )

        // When
        sut.markExpiryReissueCandidatesAsSeen()

        // Then
        wait(for: [
            vaccinationRepo.replaceExpectation
        ], timeout: 1)
    }
    
    func testRecoveryExpiryReissueCandidatesCount() {
        // Given
        configureCustomSut(
            certificates: [
                .reissuableRecovery,
                .reissuableRecovery,
                .reissuableVaccination,
            ]
        )

        // When
        let count = sut.recoveryExpiryReissueCandidatesCount

        // Then
        XCTAssertEqual(count, 1)
    }
    
    func testRecoveryExpiryReissueCandidatesCount_withNonReissuable() {
        // Given
        configureCustomSut(
            certificates: [
                .reissuableRecovery,
                .reissuableRecovery,
                .reissuableVaccination,
                .nonReissuableRecovery
            ]
        )

        // When
        let count = sut.recoveryExpiryReissueCandidatesCount

        // Then
        XCTAssertEqual(count, 0)
    }

    func testRecoveryExpiryReissueCandidatesCount_count_changed_after_refresh() {
        // Given
        configureCustomSut(
            certificates: [
                .reissuableRecovery,
                .reissuableRecovery,
                .reissuableVaccination,
                .nonReissuableRecovery
            ]
        )
        vaccinationRepo.certificates = []
        sut.refreshCertsAndUpdateView()
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 1)

        // When
        let count = sut.recoveryExpiryReissueCandidatesCount

        // Then
        XCTAssertEqual(count, 0)
    }

    func testMaskStatusViewModel_optional() {
        // When
        let viewModel = sut.maskStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderMaskNotRequiredStatusViewModel)
    }

    func testMaskStatusViewModel_required() throws {
        // Given
        certificateHolderStatusModel.needsMask = true
        try configureSut()

        // When
        let viewModel = sut.maskStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderMaskRequiredStatusViewModel)
    }

    func testMaskStatusViewModel_invalid() throws {
        // Given
        var token: ExtendedCBORWebToken = try .token2Of2Mustermann()
        token.invalid = true
        configureCustomSut(certificates: [token])

        // When
        let viewModel = sut.maskStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderInvalidMaskStatusViewModel)
    }

    func testImmunizationStatusViewModel_incomplete() {
        // When
        let viewModel = sut.immunizationStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderIncompleteImmunizationStatusViewModel)
    }
    
    func testImmunizationStatusViewModel_incomplete_because_of_missing_vaccination() throws {
        // Given
        let recovery = CBORWebToken
            .mockRecoveryCertificate
            .recoveryTestDate(Date() - 3)
            .extended()
        certificateHolderStatusModel.holderIsFullyImmunized = true
        configureCustomSut(certificates: [recovery])

        // When
        let viewModel = sut.immunizationStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderIncompleteImmunizationStatusViewModel)
    }
    
    func testImmunizationStatusViewModel_incomplete_because_to_low_doseNumber() throws {
        // Given
        let vaccination = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(1)
            .extended()
        certificateHolderStatusModel.holderIsFullyImmunized = true
        configureCustomSut(certificates: [vaccination])

        // When
        let viewModel = sut.immunizationStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderIncompleteImmunizationStatusViewModel)
    }
    
    func testImmunizationStatusViewModel_incomplete_because_of_missing_recovery() throws {
        // Given
        let vaccination = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(2)
            .extended()
        certificateHolderStatusModel.holderIsFullyImmunized = true
        configureCustomSut(certificates: [vaccination])

        // When
        let viewModel = sut.immunizationStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderIncompleteImmunizationStatusViewModel)
    }
    
    func testImmunizationStatusViewModel_complete_B2() throws {
        // Given
        let vaccination = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(4)
            .extended()
        certificateHolderStatusModel.holderIsFullyImmunized = true
        configureCustomSut(certificates: [vaccination])

        // When
        let viewModel = sut.immunizationStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderCompleteImmunizationB2StatusViewModel)
    }
    
    func testImmunizationStatusViewModel_complete_C2() throws {
        // Given
        let vaccination = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(3)
            .extended()
        certificateHolderStatusModel.holderIsFullyImmunized = true
        configureCustomSut(certificates: [vaccination])

        // When
        let viewModel = sut.immunizationStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderImmunizationC2StatusViewModel)
    }
    
    func testImmunizationStatusViewModel_complete_E2_recovery_older_than_vaccination() throws {
        // Given
        let vaccination = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationSetDate(Date() - 2)
            .doseNumber(2)
            .extended()
        let recovery = CBORWebToken
            .mockRecoveryCertificate
            .recoveryTestDate(Date() - 3)
            .extended()
        certificateHolderStatusModel.holderIsFullyImmunized = true
        configureCustomSut(certificates: [vaccination, recovery])

        // When
        let viewModel = sut.immunizationStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderImmunizationE2StatusViewModel)
    }
    
    func testImmunizationStatusViewModel_complete_E22_recovery_fresher_than_vaccination_and_revovery_frehser_than_29_days() throws {
        // Given
        let vaccination = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationSetDate(Date().add(days: -100)!)
            .doseNumber(2)
            .extended()
        let recovery = CBORWebToken
            .mockRecoveryCertificate
            .recoveryTestDate(Date().add(days: -29)! + 1)
            .extended()
        certificateHolderStatusModel.holderIsFullyImmunized = true
        configureCustomSut(certificates: [vaccination,recovery])

        // When
        let viewModel = sut.immunizationStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderImmunizationE22StatusViewModel)
        XCTAssertEqual(viewModel.description, "You are considered fully vaccinated based on your vaccination and the infection you have had. However, your immune protection is only effective in 1 days. Please bear in mind that you can still be contagious, but also inform yourself about recommended booster vaccinations")
    }
    
    func testImmunizationStatusViewModel_complete_E22_recovery_fresher_than_vaccination_and_revovery_just_done() throws {
        // Given
        let vaccination = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationSetDate(Date().add(days: -100)!)
            .doseNumber(2)
            .extended()
        let recovery = CBORWebToken
            .mockRecoveryCertificate
            .recoveryTestDate(Date() - 1)
            .extended()
        certificateHolderStatusModel.holderIsFullyImmunized = true
        configureCustomSut(certificates: [vaccination,recovery])

        // When
        let viewModel = sut.immunizationStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderImmunizationE22StatusViewModel)
        XCTAssertEqual(viewModel.description, "You are considered fully vaccinated based on your vaccination and the infection you have had. However, your immune protection is only effective in 29 days. Please bear in mind that you can still be contagious, but also inform yourself about recommended booster vaccinations")
    }
    
    func testImmunizationStatusViewModel_complete_E2_recovery_fresher_than_vaccination_and_revovery_older_than_29_days() throws {
        // Given
        let vaccinationDate = try XCTUnwrap(Date().add(days: -45))
        let recoveryDate = try XCTUnwrap(Date().add(days: -30))
        let vaccination = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationSetDate(vaccinationDate)
            .doseNumber(2)
            .extended()
        let recovery = CBORWebToken
            .mockRecoveryCertificate
            .recoveryTestDate(recoveryDate)
            .extended()
        certificateHolderStatusModel.holderIsFullyImmunized = true
        configureCustomSut(certificates: [vaccination,recovery])

        // When
        let viewModel = sut.immunizationStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderImmunizationE2StatusViewModel)
    }
    
    func testImmunizationStatusViewModel_invalid() throws {
        // Given
        var token: ExtendedCBORWebToken = try .token2Of2Mustermann()
        token.invalid = true
        configureCustomSut(certificates: [token])

        // When
        let viewModel = sut.immunizationStatusViewModel

        // Then
        XCTAssertTrue(viewModel is CertificateHolderInvalidImmunizationStatusViewModel)
    }
    
    func test_maskLink() throws {
        // When
        let maskFaqLink = sut.maskFaqLink

        // Then
        XCTAssertEqual(maskFaqLink, "#More information::https://www.digitaler-impfnachweis-app.de/en/faq/#current-most-frequently-asked-questions#")
    }
}

private extension ExtendedCBORWebToken {
    static var reissuableVaccination: Self {
        var token = CBORWebToken.mockVaccinationCertificate
        token.exp = Date()
        return token.extended(vaccinationQRCodeData: UUID().uuidString)
    }

    static var nonReissuableVaccination: Self {
        CBORWebToken.mockVaccinationCertificate.extended(
            vaccinationQRCodeData: UUID().uuidString
        )
    }

    static var reissuableRecovery: Self {
        var token = CBORWebToken.mockRecoveryCertificate
        token.exp = Date()
        return token.extended(vaccinationQRCodeData: UUID().uuidString)
    }

    static var nonReissuableRecovery: Self {
        CBORWebToken.mockRecoveryCertificate.extended(
            vaccinationQRCodeData: UUID().uuidString
        )
    }

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
