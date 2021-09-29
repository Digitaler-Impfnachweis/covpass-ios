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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValidationError_no_certificate_and_no_error() throws {
        let sut = ValidationResultFactory.createViewModel(router: ValidationResultRouterMock(),
                                                          repository: VaccinationRepositoryMock(),
                                                          certificate: nil,
                                                          error: nil,
                                                          certLogic: DCCCertLogicMock())
        let expectedError = ValidationResultError.technical
        XCTAssertTrue(sut is ErrorResultViewModel, "Wrong Type: should be ErrorResultViewModel")
        let errorModel = sut as! ErrorResultViewModel
        XCTAssertTrue(errorModel.error is ValidationResultError, "Wrong Type: should be ValidationResultError")
        let error = errorModel.error as! ValidationResultError
        XCTAssertTrue(error == expectedError, "Wrong Error")
    }

    func testValidationError_certificate_and_no_error() throws {
        let sut = ValidationResultFactory.createViewModel(router: ValidationResultRouterMock(),
                                                          repository: VaccinationRepositoryMock(),
                                                          certificate: CBORWebToken.mockTestCertificate,
                                                          error: nil)
        let expectedError = ValidationResultError.functional

        XCTAssertTrue(sut is ErrorResultViewModel, "Wrong Type: should be ErrorResultViewModel")
        let errorModel = try XCTUnwrap(sut as? ErrorResultViewModel)
        XCTAssertTrue(errorModel.error is ValidationResultError, "Wrong Type: should be ValidationResultError")
        let error = try XCTUnwrap(errorModel.error as? ValidationResultError)
        XCTAssertTrue(error == expectedError, "Wrong Error")
    }

    func testValidationError_certificate_and_error() throws {
        let sut = ValidationResultFactory.createViewModel(router: ValidationResultRouterMock(),
                                                          repository: VaccinationRepositoryMock(),
                                                          certificate: CBORWebToken.mockTestCertificate,
                                                          error: CertificateError.expiredCertifcate)
        let expectedError = CertificateError.expiredCertifcate

        XCTAssertTrue(sut is ErrorResultViewModel, "Wrong Type: should be ErrorResultViewModel")
        let errorModel = try XCTUnwrap(sut as? ErrorResultViewModel)
        XCTAssertTrue(errorModel.error is CertificateError, "Wrong Type: should be ValidationResultError")
        let error = try XCTUnwrap(errorModel.error as? CertificateError)
        XCTAssertTrue(error == expectedError, "Wrong Error")
    }

    func testValidationError_certificate_and_no_error_validationResult_isEmpty_technical_Error() throws {
        let certLogic = DCCCertLogicMock()
        certLogic.validateResult = []
        let sut = ValidationResultFactory.createViewModel(router: ValidationResultRouterMock(),
                                                          repository: VaccinationRepositoryMock(),
                                                          certificate: CBORWebToken.mockVaccinationCertificate,
                                                          error: nil,
                                                          certLogic: certLogic)
        let expectedError = ValidationResultError.technical

        XCTAssertTrue(sut is ErrorResultViewModel, "Wrong Type: should be ErrorResultViewModel")
        let errorModel = try XCTUnwrap(sut as? ErrorResultViewModel)
        XCTAssertTrue(errorModel.error is ValidationResultError, "Wrong Type: should be ValidationResultError")
        let error = try XCTUnwrap(errorModel.error as? ValidationResultError)
        XCTAssertTrue(error == expectedError, "Wrong Error: \(error)")
    }

    func testValidationError_certificate_and_no_error_catch_technical_Error() throws {
        let sut = ValidationResultFactory.createViewModel(router: ValidationResultRouterMock(),
                                                          repository: VaccinationRepositoryMock(),
                                                          certificate: CBORWebToken.mockVaccinationCertificate,
                                                          error: nil,
                                                          type: .booster)
        let expectedError = ValidationResultError.technical

        XCTAssertTrue(sut is ErrorResultViewModel, "Wrong Type: should be ErrorResultViewModel")
        let errorModel = try XCTUnwrap(sut as? ErrorResultViewModel)
        XCTAssertTrue(errorModel.error is ValidationResultError, "Wrong Type: should be ValidationResultError")
        let error = try XCTUnwrap(errorModel.error as? ValidationResultError)
        XCTAssertTrue(error == expectedError, "Wrong Error: \(error)")
    }

    func testValidationError_certificate_and_recoverResultViewModel() throws {
        let expectedCertificate = CBORWebToken.mockRecoveryCertificate
        let certLogic = DCCCertLogicMock()
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = ValidationResultFactory.createViewModel(router: ValidationResultRouterMock(),
                                                          repository: VaccinationRepositoryMock(),
                                                          certificate: expectedCertificate,
                                                          error: nil,
                                                          certLogic: certLogic)

        XCTAssertTrue(sut is RecoveryResultViewModel, "Wrong Type: should be RecoveryResultViewModel")
        let resultModel = try XCTUnwrap(sut as? RecoveryResultViewModel)
        XCTAssertTrue(resultModel.certificate == expectedCertificate)
    }

    func testValidationError_certificate_and_TestResultViewModel() throws {
        let expectedCertificate = CBORWebToken.mockTestCertificate
        let certLogic = DCCCertLogicMock()
        certLogic.validateResult = [ValidationResult(rule: .mock, result: .passed, validationErrors: nil)]
        let sut = ValidationResultFactory.createViewModel(router: ValidationResultRouterMock(),
                                                          repository: VaccinationRepositoryMock(),
                                                          certificate: expectedCertificate,
                                                          error: nil,
                                                          certLogic: certLogic)

        XCTAssertTrue(sut is TestResultViewModel, "Wrong Type: should be TestResultViewModel")
        let resultModel = try XCTUnwrap(sut as? TestResultViewModel)
        XCTAssertTrue(resultModel.certificate == expectedCertificate)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
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
