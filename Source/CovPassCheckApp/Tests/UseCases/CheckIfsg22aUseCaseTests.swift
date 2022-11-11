//
//  CheckIfsg22aUseCaseTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
import CovPassCommon
@testable import CovPassCheckApp

class CheckIfsg22aUseCaseTests: XCTestCase {
    
    var sut: CheckIfsg22aUseCase!
    var certificateHolderStatusModel: CertificateHolderStatusModelMock!
    var revocationRepository: CertificateRevocationRepositoryMock!
    var token: ExtendedCBORWebToken!
    
    override func setUpWithError() throws {
        token = CBORWebToken.mockRecoveryCertificate.mockRecoveryUVCI("FOO").extended()
        revocationRepository = CertificateRevocationRepositoryMock()
        certificateHolderStatusModel = CertificateHolderStatusModelMock()
        sut = CheckIfsg22aUseCase(token: token,
                                  revocationRepository: revocationRepository,
                                  holderStatus: certificateHolderStatusModel,
                                  additionalToken: nil)
    }
    
    override func tearDownWithError() throws {
        revocationRepository = nil
        certificateHolderStatusModel = nil
        token = nil
        sut = nil
    }
    
    func test_checkIfsg22aRulesNotAvailable() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because rules are not available")
        certificateHolderStatusModel.areIfsg22aRulesAvailable = false
        // WHEN
        sut.execute()
            .done { token in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckIfsg22aUseCaseError, .ifsg22aRulesNotAvailable(self.token))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_certificate_is_revoked() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because certificate is revoked")
        certificateHolderStatusModel.areIfsg22aRulesAvailable = true
        revocationRepository.isRevoked = true
        // WHEN
        sut.execute()
            .done { token in
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
        certificateHolderStatusModel.isVaccinationCycleComplete = false
        // WHEN
        sut.execute()
            .done { token in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckIfsg22aUseCaseError, .vaccinationCycleIsNotComplete(self.token))
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
        certificateHolderStatusModel.isVaccinationCycleComplete = true
        // WHEN
        sut.execute()
            .done { token in
                XCTAssertNotNil(token)
                XCTAssertEqual(token, self.token)
                expectation.fulfill()
            }
            .catch { error in
                // THEN

                XCTFail("Should not Fail")
            }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_checkIfsg22aRule_withAdditional_token_of_different_person_failed() {
        // GIVEN
        let differentPersonToken = CBORWebToken.mockVaccinationCertificateWithOtherName.extended(vaccinationQRCodeData: "1")
        let sut = CheckIfsg22aUseCase(token: token,
                                      revocationRepository: revocationRepository,
                                      holderStatus: certificateHolderStatusModel,
                                      additionalToken: differentPersonToken)
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areIfsg22aRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.isVaccinationCycleComplete = true
        // WHEN
        sut.execute()
            .done { token in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckIfsg22aUseCaseError, .showMaskCheckdifferentPersonalInformation(self.token, differentPersonToken))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_checkMaskRule_withAdditional_token_of_same_type_failed() {
        // GIVEN
        let differentPersonToken = CBORWebToken.mockRecoveryCertificate.extended()
        let sut = CheckIfsg22aUseCase(token: token,
                                      revocationRepository: revocationRepository,
                                      holderStatus: certificateHolderStatusModel,
                                      additionalToken: differentPersonToken)
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areIfsg22aRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.isVaccinationCycleComplete = false
        // WHEN
        sut.execute()
            .done { token in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? CheckIfsg22aUseCaseError, .secondScanSameToken(differentPersonToken))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }
}
