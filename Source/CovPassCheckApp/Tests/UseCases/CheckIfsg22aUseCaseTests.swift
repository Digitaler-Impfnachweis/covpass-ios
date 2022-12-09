//
//  CheckIfsg22aUseCaseTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

class CheckIfsg22aUseCaseTests: XCTestCase {
    var sut: CheckIfsg22aUseCase!
    var certificateHolderStatusModel: CertificateHolderStatusModelMock!
    var revocationRepository: CertificateRevocationRepositoryMock!
    var token: ExtendedCBORWebToken!

    override func setUpWithError() throws {
        token = CBORWebToken.mockRecoveryCertificate.mockRecoveryUVCI("FOO").extended()
        revocationRepository = CertificateRevocationRepositoryMock()
        certificateHolderStatusModel = CertificateHolderStatusModelMock()
        sut = CheckIfsg22aUseCase(currentToken: token,
                                  revocationRepository: revocationRepository,
                                  holderStatus: certificateHolderStatusModel,
                                  secondScannedToken: nil,
                                  firstScannedToken: nil,
                                  ignoringPiCheck: false)
    }

    override func tearDownWithError() throws {
        revocationRepository = nil
        certificateHolderStatusModel = nil
        token = nil
        sut = nil
    }

    func test_certificate_is_revoked() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because certificate is revoked")
        certificateHolderStatusModel.areIfsg22aRulesAvailable = true
        revocationRepository.isRevoked = true
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CertificateError, .revoked(self.token))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkIfsg22aRule() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because holders vaccination cycle is not complete")
        certificateHolderStatusModel.areIfsg22aRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.isVaccinationCycleComplete.passed = false
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckIfsg22aUseCaseError, .vaccinationCycleIsNotComplete(self.token, nil, nil))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkIfsg22a_rules_passed() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areIfsg22aRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.isVaccinationCycleComplete.passed = true
        // WHEN
        sut.execute()
            .done { token in
                XCTAssertNotNil(token)
                XCTAssertEqual(token, self.token)
                expectation.fulfill()
            }
            .catch { _ in
                // THEN

                XCTFail("Should not Fail")
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkIfsg22aRule_withAdditional_token_of_different_person_failed() {
        // GIVEN
        let differentPersonToken = CBORWebToken.mockVaccinationCertificateWithOtherName.extended(vaccinationQRCodeData: "1")
        let sut = CheckIfsg22aUseCase(currentToken: token,
                                      revocationRepository: revocationRepository,
                                      holderStatus: certificateHolderStatusModel,
                                      secondScannedToken: differentPersonToken,
                                      firstScannedToken: nil,
                                      ignoringPiCheck: false)
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areIfsg22aRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.isVaccinationCycleComplete.passed = true
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckIfsg22aUseCaseError, .differentPersonalInformation(differentPersonToken, self.token, nil))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkIfsg22aRule_withAdditional_but_same_token_second_scan() {
        // GIVEN
        let sut = CheckIfsg22aUseCase(currentToken: token,
                                      revocationRepository: revocationRepository,
                                      holderStatus: certificateHolderStatusModel,
                                      secondScannedToken: token,
                                      firstScannedToken: nil,
                                      ignoringPiCheck: false)
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areIfsg22aRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.isVaccinationCycleComplete.passed = true
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckIfsg22aUseCaseError, .secondScanSameToken(self.token))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkIfsg22aRule_withAdditional_but_same_token_third_scan() {
        // GIVEN
        let firstScannedToken: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        let sut = CheckIfsg22aUseCase(currentToken: token,
                                      revocationRepository: revocationRepository,
                                      holderStatus: certificateHolderStatusModel,
                                      secondScannedToken: token,
                                      firstScannedToken: firstScannedToken,
                                      ignoringPiCheck: false)
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areIfsg22aRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.isVaccinationCycleComplete.passed = true
        // WHEN
        sut.execute()
            .done { _ in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckIfsg22aUseCaseError, .thirdScanSameToken(self.token, firstScannedToken))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }
}
