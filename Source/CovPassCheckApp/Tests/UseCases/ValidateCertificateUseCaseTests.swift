//
//  ValidationUseCase.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
import CovPassCommon
@testable import CovPassCheckApp

class ValidateCertificateUseCaseTests: XCTestCase {
    
    var sut: ValidateCertificateUseCase!
    var certificateHolderStatusModel: CertificateHolderStatusModelMock!
    var revocationRepository: CertificateRevocationRepositoryMock!
    var token: ExtendedCBORWebToken!
    
    override func setUpWithError() throws {
        token = CBORWebToken.mockRecoveryCertificate.mockRecoveryUVCI("FOO").extended()
        revocationRepository = CertificateRevocationRepositoryMock()
        certificateHolderStatusModel = CertificateHolderStatusModelMock()
        sut = ValidateCertificateUseCase(token: token,
                                         region: nil,
                                         revocationRepository: revocationRepository,
                                         holderStatus: certificateHolderStatusModel)
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
            .done { token in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? ValidateCertificateUseCaseError, .maskRulesNotAvailable(self.token))
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
    
    func test_checkDomesticRules_failedFunctional() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because rules are not passed")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticRulesPassedResult = .failedFunctional
        // WHEN
        sut.execute()
            .done { token in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? ValidateCertificateUseCaseError, .invalidDueToRules(self.token))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_checkDomesticRules_failedTechnical() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because rules are not passed")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticRulesPassedResult = .failedTechnical
        // WHEN
        sut.execute()
            .done { token in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? ValidateCertificateUseCaseError, .invalidDueToTechnicalReason(self.token))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_euInvalidationRules_failedFunctional() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because rules are not passed")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticRulesPassedResult = .passed
        certificateHolderStatusModel.euInvalidationRulesPassedResult = .failedFunctional
        // WHEN
        sut.execute()
            .done { token in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? ValidateCertificateUseCaseError, .invalidDueToRules(self.token))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_euInvalidationRules_failedTechnical() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because rules are not passed")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticRulesPassedResult = .passed
        certificateHolderStatusModel.euInvalidationRulesPassedResult = .failedTechnical
        // WHEN
        sut.execute()
            .done { token in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? ValidateCertificateUseCaseError, .invalidDueToTechnicalReason(self.token))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_checkMaskRule() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticRulesPassedResult = .passed
        certificateHolderStatusModel.euInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.needsMask = true
        // WHEN
        sut.execute()
            .done { token in
                XCTFail("Should not successful")
            }
            .catch { error in
                // THEN
                XCTAssertEqual(error as? ValidateCertificateUseCaseError, .holderNeedsMask(self.token))
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_checkMaskRule_passed() {
        // GIVEN
        let expectation = XCTestExpectation(description: "test should fail because holder needs mask")
        certificateHolderStatusModel.areMaskRulesAvailable = true
        revocationRepository.isRevoked = false
        certificateHolderStatusModel.domesticRulesPassedResult = .passed
        certificateHolderStatusModel.euInvalidationRulesPassedResult = .passed
        certificateHolderStatusModel.needsMask = false
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
}
