//
//  CheckMaskRulesUseCaseTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

class CheckMaskRulesUseCaseTests: XCTestCase {
    var sut: CheckMaskRulesUseCase!
    var certificateHolderStatusModel: CertificateHolderStatusModelMock!
    var revocationRepository: CertificateRevocationRepositoryMock!
    var token: ExtendedCBORWebToken!

    override func setUpWithError() throws {
        token = CBORWebToken.mockRecoveryCertificate.mockRecoveryUVCI("FOO").extended()
        revocationRepository = CertificateRevocationRepositoryMock()
        certificateHolderStatusModel = CertificateHolderStatusModelMock()
        sut = CheckMaskRulesUseCase(region: nil,
                                    revocationRepository: revocationRepository,
                                    holderStatus: certificateHolderStatusModel,
                                    tokens: [token],
                                    ignoringPiCheck: false)
    }

    override func tearDownWithError() throws {
        revocationRepository = nil
        certificateHolderStatusModel = nil
        token = nil
        sut = nil
    }

    func test_checkMaskRulesNotAvailable() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because rules are not available")
        certificateHolderStatusModel.areMaskRulesAvailable = false
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckMaskRulesUseCaseError, .maskRulesNotAvailable)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_certificate_is_revoked() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because certificate is revoked")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = true
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckMaskRulesUseCaseError, .invalidToken)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkDomesticRules_failedFunctional() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because rules are not passed")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticAcceptanceAndInvalidationRulesPassedResult = .failedFunctional
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckMaskRulesUseCaseError, .invalidToken)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkDomesticRules_failedTechnical() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because rules are not passed")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticAcceptanceAndInvalidationRulesPassedResult = .failedTechnical
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckMaskRulesUseCaseError, .invalidToken)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_euInvalidationRules_failedFunctional() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because rules are not passed")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticAcceptanceAndInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.euInvalidationRulesPassedResult = .failedFunctional
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckMaskRulesUseCaseError, .invalidToken)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_euInvalidationRules_failedTechnical() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because rules are not passed")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticAcceptanceAndInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.euInvalidationRulesPassedResult = .failedTechnical
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckMaskRulesUseCaseError, .invalidToken)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkMaskRule() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticAcceptanceAndInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.euInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.needsMask = true
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckMaskRulesUseCaseError, .holderNeedsMask)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkMaskRule_passed() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticAcceptanceAndInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.euInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.needsMask = false
        // WHEN
        sut.execute()
            .done {
                expectation.fulfill()
            }
            .catch { _ in
                // THEN

                XCTFail("Should not Fail")
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkMaskRule_withAdditional_token_of_different_person_failed() {
        // GIVEN
        let differentPersonToken = CBORWebToken.mockVaccinationCertificateWithOtherName.extended(vaccinationQRCodeData: "3")
        let sut = CheckMaskRulesUseCase(region: nil,
                                        revocationRepository: revocationRepository,
                                        holderStatus: certificateHolderStatusModel,
                                        tokens: [token, differentPersonToken],
                                        ignoringPiCheck: false)
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticAcceptanceAndInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.euInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.needsMask = false
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckMaskRulesUseCaseError, .differentPersonalInformation)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkMaskRule_withAdditional_same_token_of() {
        // GIVEN
        let sut = CheckMaskRulesUseCase(region: nil,
                                        revocationRepository: revocationRepository,
                                        holderStatus: certificateHolderStatusModel,
                                        tokens: [token, token],
                                        ignoringPiCheck: false)
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticAcceptanceAndInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.euInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.needsMask = false
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckMaskRulesUseCaseError, .secondScanSameToken)
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }
}
