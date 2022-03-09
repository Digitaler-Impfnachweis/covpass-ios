//
//  ValidationResultFactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest
import CovPassUI
import PromiseKit
import CertLogic

class ValidationResultFactoryTests: XCTestCase {
    
    var resolver: Resolver<CBORWebToken>!
    var persistence: UserDefaultsPersistence!
    var validationResultRouter: ValidationResultRouterMock!
    var vacRepo: VaccinationRepositoryMock!
    var certLogic: DCCCertLogicMock!
    
    override func setUpWithError() throws {
        resolver = Promise<CBORWebToken>.pending().resolver
        persistence = UserDefaultsPersistence()
        validationResultRouter = ValidationResultRouterMock()
        vacRepo = VaccinationRepositoryMock()
        certLogic = DCCCertLogicMock()
    }
    
    override func tearDown() {
        resolver = nil
        persistence = nil
        validationResultRouter = nil
        vacRepo = nil
        certLogic = nil
    }
    
    func viewModel(certificate: CBORWebToken? = nil,
             error: CertificateError? = nil,
             logicType: DCCCertLogic.LogicType = .eu) -> ValidationResultViewModel {
        return ValidationResultFactory.createViewModel(resolvable: resolver,
                                                       router: validationResultRouter,
                                                       repository: vacRepo,
                                                       certificate: certificate,
                                                       error: error,
                                                       type: logicType,
                                                       certLogic: certLogic,
                                                       _2GContext: false,
                                                       userDefaults: persistence)
    }
    
    func testValidationError_no_certificate_and_no_error() throws {
        let sut = viewModel()
        let expectedError = ValidationResultError.technical
        XCTAssertTrue(sut is ErrorResultViewModel, "Wrong Type: should be ErrorResultViewModel")
        let errorModel = sut as! ErrorResultViewModel
        XCTAssertTrue(errorModel.error is ValidationResultError, "Wrong Type: should be ValidationResultError")
        let error = errorModel.error as! ValidationResultError
        XCTAssertTrue(error == expectedError, "Wrong Error")
    }
    
    func testValidationError_certificate_and_no_error() throws {
        let sut = viewModel()
        let expectedError = ValidationResultError.technical
        XCTAssertTrue(sut is ErrorResultViewModel, "Wrong Type: should be ErrorResultViewModel")
        let errorModel = try XCTUnwrap(sut as? ErrorResultViewModel)
        XCTAssertTrue(errorModel.error is ValidationResultError, "Wrong Type: should be ValidationResultError")
        let error = try XCTUnwrap(errorModel.error as? ValidationResultError)
        XCTAssertTrue(error == expectedError, "Wrong Error")
    }
    
    func testValidationError_certificate_and_error() throws {
        let sut = viewModel(certificate: .mockTestCertificate, error: .expiredCertifcate)
        let expectedError = CertificateError.expiredCertifcate
        XCTAssertTrue(sut is ErrorResultViewModel, "Wrong Type: should be ErrorResultViewModel")
        let errorModel = try XCTUnwrap(sut as? ErrorResultViewModel)
        XCTAssertTrue(errorModel.error is CertificateError, "Wrong Type: should be ValidationResultError")
        let error = try XCTUnwrap(errorModel.error as? CertificateError)
        XCTAssertTrue(error == expectedError, "Wrong Error")
    }
    
    func testValidationError_certificate_and_no_error_validationResult_isEmpty_technical_Error() throws {
        let sut = viewModel()
        let expectedError = ValidationResultError.technical
        XCTAssertTrue(sut is ErrorResultViewModel, "Wrong Type: should be ErrorResultViewModel")
        let errorModel = try XCTUnwrap(sut as? ErrorResultViewModel)
        XCTAssertTrue(errorModel.error is ValidationResultError, "Wrong Type: should be ValidationResultError")
        let error = try XCTUnwrap(errorModel.error as? ValidationResultError)
        XCTAssertTrue(error == expectedError, "Wrong Error: \(error)")
    }
    
    func testValidationError_certificate_and_no_error_catch_technical_Error() throws {
        let sut = viewModel(logicType: .booster)
        let expectedError = ValidationResultError.technical
        XCTAssertTrue(sut is ErrorResultViewModel, "Wrong Type: should be ErrorResultViewModel")
        let errorModel = try XCTUnwrap(sut as? ErrorResultViewModel)
        XCTAssertTrue(errorModel.error is ValidationResultError, "Wrong Type: should be ValidationResultError")
        let error = try XCTUnwrap(errorModel.error as? ValidationResultError)
        XCTAssertTrue(error == expectedError, "Wrong Error: \(error)")
    }
    
    func testValidationError_certificate_and_recoverResultViewModel() throws {
        let expectedCertificate = CBORWebToken.mockRecoveryCertificate
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut is RecoveryResultViewModel, "Wrong Type: should be RecoveryResultViewModel")
        let resultModel = try XCTUnwrap(sut as? RecoveryResultViewModel)
        XCTAssertTrue(resultModel.certificate == expectedCertificate)
        XCTAssertTrue(resultModel.certificate != .mockVaccinationCertificate)
    }
    
    func testValidationError_certificate_and_TestResultViewModel() throws {
        let expectedCertificate = CBORWebToken.mockTestCertificate
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut is TestResultViewModel, "Wrong Type: should be TestResultViewModel")
        let resultModel = try XCTUnwrap(sut as? TestResultViewModel)
        XCTAssertTrue(resultModel.certificate == expectedCertificate)
    }
}

class ValidationResultFactoryExpertModeTests: XCTestCase {
    var resolver: Resolver<CBORWebToken>!
    var persistence: UserDefaultsPersistence!
    var validationResultRouter: ValidationResultRouterMock!
    var vacRepo: VaccinationRepositoryMock!
    var certLogic: DCCCertLogicMock!
    
    override func setUpWithError() throws {
        resolver = Promise<CBORWebToken>.pending().resolver
        persistence = UserDefaultsPersistence()
        validationResultRouter = ValidationResultRouterMock()
        vacRepo = VaccinationRepositoryMock()
        certLogic = DCCCertLogicMock()
    }
    
    override func tearDown() {
        resolver = nil
        persistence = nil
        validationResultRouter = nil
        vacRepo = nil
        certLogic = nil
    }
    
    func viewModel(certificate: CBORWebToken? = nil,
             error: CertificateError? = nil,
             logicType: DCCCertLogic.LogicType = .eu) -> ValidationResultViewModel {
        return ValidationResultFactory.createViewModel(resolvable: resolver,
                                                       router: validationResultRouter,
                                                       repository: vacRepo,
                                                       certificate: certificate,
                                                       error: error,
                                                       type: logicType,
                                                       certLogic: certLogic,
                                                       _2GContext: false,
                                                       userDefaults: persistence)
    }
    
    func testValidationError_someCert_expertModeOff_someErrorWhileCertLogicThrown_linkIsHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = CBORWebToken.mockTestCertificate
        certLogic.validationError = APIError.invalidResponse
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.linkIsHidden)
    }
    
    func testValidationError_someCert_expertModeOff_validationEmpty_linkIsHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = CBORWebToken.mockTestCertificate
        certLogic.validateResult = []
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.linkIsHidden)
    }
    
    
    func testValidationError_someCert_expertModeOff_validationFailing_linkIsHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = CBORWebToken.mockTestCertificate
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .fail, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.linkIsHidden)
    }
    
    func testValidationError_missingCert_expertModeOff_linkIsHidden() throws {
        persistence.revocationExpertMode = false
        let sut = viewModel()
        XCTAssertTrue(sut.linkIsHidden)
    }
    
    func testValidationError_testCert_expertModeOff_linkIsHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = CBORWebToken.mockTestCertificate
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.linkIsHidden)
    }
    
    func testValidationError_vacCert_expertModeOff_linkIsHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = CBORWebToken.mockVaccinationCertificate
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.linkIsHidden)
    }
    
    func testValidationError_recCert_expertModeOff_linkIsHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = CBORWebToken.mockRecoveryCertificate
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.linkIsHidden)
    }
    
    func testValidationError_testCert_expertModeOn_linkIsNotHidden() throws {
        persistence.revocationExpertMode = true
        let expectedCertificate = CBORWebToken.mockTestCertificate
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertFalse(sut.linkIsHidden)
    }
    
    func testValidationError_vacCert_expertModeOn_linkIsNotHidden() throws {
        persistence.revocationExpertMode = true
        let expectedCertificate = CBORWebToken.mockVaccinationCertificate
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertFalse(sut.linkIsHidden)
    }
    
    func testValidationError_recCert_expertModeOn_linkIsNotHidden() throws {
        persistence.revocationExpertMode = true
        let expectedCertificate = CBORWebToken.mockRecoveryCertificate
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertFalse(sut.linkIsHidden)
    }
}

extension HealthCertificateClaim: Equatable {
    public static func == (lhs: HealthCertificateClaim, rhs: HealthCertificateClaim) -> Bool {
        lhs.dgc == rhs.dgc
    }
    
    
}

extension CBORWebToken: Equatable {
    public static func == (lhs: CBORWebToken, rhs: CBORWebToken) -> Bool {
        lhs.expiresSoon == rhs.expiresSoon &&
        lhs.isExpired == rhs.isExpired &&
        lhs.isInvalid == rhs.isExpired &&
        lhs.exp == rhs.exp &&
        lhs.hcert == rhs.hcert &&
        lhs.exp == rhs.exp &&
        lhs.iat == rhs.iat &&
        lhs.iss == rhs.iss
    }
}
