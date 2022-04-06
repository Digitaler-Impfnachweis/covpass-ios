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
    
    var resolver: Resolver<ExtendedCBORWebToken>!
    var persistence: UserDefaultsPersistence!
    var validationResultRouter: ValidationResultRouterMock!
    var vacRepo: VaccinationRepositoryMock!
    var certLogic: DCCCertLogicMock!
    
    override func setUpWithError() throws {
        resolver = Promise<ExtendedCBORWebToken>.pending().resolver
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
    
    func viewModel(certificate: ExtendedCBORWebToken? = nil,
                   error: CertificateError? = nil,
                   logicType: DCCCertLogic.LogicType = .eu) -> ValidationResultViewModel {
        return ValidationResultFactory.createViewModel(resolvable: resolver,
                                                       router: validationResultRouter,
                                                       repository: vacRepo,
                                                       certificate: certificate,
                                                       error: error,
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
        let sut = viewModel(
            certificate: ExtendedCBORWebToken(
                vaccinationCertificate: .mockTestCertificate,
                vaccinationQRCodeData: ""
            ),
            error: .expiredCertifcate
        )
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
        let expectedCertificate = ExtendedCBORWebToken(
            vaccinationCertificate: .mockRecoveryCertificate,
            vaccinationQRCodeData: ""
        )
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut is RecoveryResultViewModel, "Wrong Type: should be RecoveryResultViewModel")
        let resultModel = try XCTUnwrap(sut as? RecoveryResultViewModel)
        XCTAssertTrue(resultModel.certificate == expectedCertificate)
        XCTAssertTrue(resultModel.certificate?.vaccinationCertificate != .mockVaccinationCertificate)
    }
    
    func testValidationError_certificate_and_TestResultViewModel() throws {
        let expectedCertificate = ExtendedCBORWebToken(
            vaccinationCertificate: .mockTestCertificate,
            vaccinationQRCodeData: ""
        )
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut is TestResultViewModel, "Wrong Type: should be TestResultViewModel")
        let resultModel = try XCTUnwrap(sut as? TestResultViewModel)
        XCTAssertTrue(resultModel.certificate == expectedCertificate)
    }
}

class ValidationResultFactoryExpertModeTests: XCTestCase {
    var resolver: Resolver<ExtendedCBORWebToken>!
    var persistence: UserDefaultsPersistence!
    var validationResultRouter: ValidationResultRouterMock!
    var vacRepo: VaccinationRepositoryMock!
    var certLogic: DCCCertLogicMock!
    
    override func setUpWithError() throws {
        resolver = Promise<ExtendedCBORWebToken>.pending().resolver
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
    
    func viewModel(certificate: ExtendedCBORWebToken? = nil,
             error: CertificateError? = nil,
             logicType: DCCCertLogic.LogicType = .eu) -> ValidationResultViewModel {
        return ValidationResultFactory.createViewModel(resolvable: resolver,
                                                       router: validationResultRouter,
                                                       repository: vacRepo,
                                                       certificate: certificate,
                                                       error: error,
                                                       _2GContext: false,
                                                       userDefaults: persistence)
    }
    
    func testValidationError_someCert_expertModeOff_someErrorWhileCertLogicThrown_revocationInfoHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = ExtendedCBORWebToken(
            vaccinationCertificate: .mockTestCertificate,
            vaccinationQRCodeData: ""
        )
        certLogic.validationError = APIError.invalidResponse
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.revocationInfoHidden)
    }
    
    func testValidationError_someCert_expertModeOff_validationEmpty_revocationInfoHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = ExtendedCBORWebToken(
            vaccinationCertificate: .mockTestCertificate,
            vaccinationQRCodeData: ""
        )
        certLogic.validateResult = []
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.revocationInfoHidden)
    }
    
    
    func testValidationError_someCert_expertModeOff_validationFailing_revocationInfoHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = ExtendedCBORWebToken(
            vaccinationCertificate: .mockTestCertificate,
            vaccinationQRCodeData: ""
        )
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .fail, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.revocationInfoHidden)
    }
    
    func testValidationError_missingCert_expertModeOff_revocationInfoHidden() throws {
        persistence.revocationExpertMode = false
        let sut = viewModel()
        XCTAssertTrue(sut.revocationInfoHidden)
    }
    
    func testValidationError_testCert_expertModeOff_revocationInfoHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = ExtendedCBORWebToken(
            vaccinationCertificate: .mockTestCertificate,
            vaccinationQRCodeData: ""
        )
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.revocationInfoHidden)
    }
    
    func testValidationError_vacCert_expertModeOff_revocationInfoHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: ""
        )
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.revocationInfoHidden)
    }
    
    func testValidationError_recCert_expertModeOff_revocationInfoHidden() throws {
        persistence.revocationExpertMode = false
        let expectedCertificate = ExtendedCBORWebToken(
            vaccinationCertificate: .mockRecoveryCertificate,
            vaccinationQRCodeData: ""
        )
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertTrue(sut.revocationInfoHidden)
    }
    
    func testValidationError_testCert_expertModeOn_revocationInfoHidden() throws {
        persistence.revocationExpertMode = true
        let expectedCertificate = ExtendedCBORWebToken(
            vaccinationCertificate: .mockTestCertificate,
            vaccinationQRCodeData: ""
        )
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertFalse(sut.revocationInfoHidden)
    }
    
    func testValidationError_vacCert_expertModeOn_revocationInfoHidden() throws {
        persistence.revocationExpertMode = true
        let expectedCertificate = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: ""
        )
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertFalse(sut.revocationInfoHidden)
    }
    
    func testValidationError_recCert_expertModeOn_revocationInfoHidden() throws {
        persistence.revocationExpertMode = true
        let expectedCertificate = ExtendedCBORWebToken(
            vaccinationCertificate: .mockVaccinationCertificate,
            vaccinationQRCodeData: ""
        )
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = viewModel(certificate: expectedCertificate)
        XCTAssertFalse(sut.revocationInfoHidden)
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
