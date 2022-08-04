//
//  RuleCheckDetailViewControllerTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//


@testable import CovPassApp
import PromiseKit
import XCTest
import CertLogic
import SwiftyJSON

class RuleCheckDetailViewControllerTests: BaseSnapShotTests {
    
    var acceptanceRule: Rule!
    var invalidationRule: Rule!
    var validationResultPassedAcceptanceRule: ValidationResult!
    var validationResultPassedWithoutRule: ValidationResult!
    var validationResultPassedWithInvalidationRule: ValidationResult!
    var validationResultFailedAcceptanceRule: ValidationResult!
    var validationResultOpenAcceptanceRule: ValidationResult!

    override func setUp() {
        super.setUp()
        acceptanceRule = Rule(identifier: "",
                               type: "Acceptance",
                               version: "",
                               schemaVersion: "",
                               engine: "",
                               engineVersion: "",
                               certificateType: "",
                               description: [],
                               validFrom: "",
                               validTo: "",
                               affectedString: [],
                               logic: JSON(""),
                               countryCode: "")
        invalidationRule = Rule(identifier: "",
                                 type: "Invalidation",
                                 version: "",
                                 schemaVersion: "",
                                 engine: "",
                                 engineVersion: "",
                                 certificateType: "",
                                 description: [],
                                 validFrom: "",
                                 validTo: "",
                                 affectedString: [],
                                 logic: JSON(""),
                                 countryCode: "")
        validationResultPassedAcceptanceRule = ValidationResult(rule: acceptanceRule, result: .passed, validationErrors: [])
        validationResultPassedWithoutRule = ValidationResult(rule: nil, result: .passed, validationErrors: [])
        validationResultPassedWithInvalidationRule = ValidationResult(rule: invalidationRule, result: .passed, validationErrors: [])
        validationResultFailedAcceptanceRule = ValidationResult(rule: acceptanceRule, result: .fail, validationErrors: [])
        validationResultOpenAcceptanceRule = ValidationResult(rule: acceptanceRule, result: .open, validationErrors: [])
    }
    
    override func tearDown() {
        acceptanceRule = nil
        invalidationRule = nil
        validationResultPassedAcceptanceRule = nil
        validationResultPassedWithoutRule = nil
        validationResultPassedWithInvalidationRule = nil
        validationResultFailedAcceptanceRule = nil
        validationResultOpenAcceptanceRule = nil
        super.tearDown()
    }
    
    func configureSut(result: CertificateResult) -> RuleCheckDetailViewController {
        let (_, resolver) = Promise<Void>.pending()
        let viewModel = RuleCheckDetailViewModel(
            router: RuleCheckDetailRouterMock(),
            resolvable: resolver,
            result: result,
            country: "DE",
            date: .init(timeIntervalSinceReferenceDate: 0)
        )
        return .init(viewModel: viewModel)
    }
    
    func testDefault() throws {
        // Then
        let result = try CertificateResult(certificate: .mock(), result: [])
        let sut = configureSut(result: result)
        verifyView(view: sut.view, height: 2000)
    }
    
    func test_5_acceptance_rules_passed() throws {
        let validationResult: [ValidationResult] = [validationResultPassedAcceptanceRule,
                                                    validationResultPassedAcceptanceRule,
                                                    validationResultPassedAcceptanceRule,
                                                    validationResultPassedAcceptanceRule,
                                                    validationResultPassedAcceptanceRule,
                                                    validationResultPassedWithoutRule,
                                                    validationResultPassedWithInvalidationRule]
        let result = try CertificateResult(certificate: .mock(), result: validationResult)
        let sut = configureSut(result: result)
        verifyView(view: sut.view, height: 2000)
    }
    
    func test_1_passed_without_rule() throws {
        let validationResult: [ValidationResult] = [validationResultPassedWithoutRule]
        let result = try CertificateResult(certificate: .mock(), result: validationResult)
        let sut = configureSut(result: result)
        verifyView(view: sut.view, height: 2000)
    }
    
    func test_3_invalidation_rules_passed() throws {
        let validationResult: [ValidationResult] = [validationResultPassedWithInvalidationRule,
                                                    validationResultPassedWithInvalidationRule,
                                                    validationResultPassedWithInvalidationRule]
        let result = try CertificateResult(certificate: .mock(), result: validationResult)
        let sut = configureSut(result: result)
        verifyView(view: sut.view, height: 2000)
    }
    
    func test_1_rule_failed() throws {
        let validationResult: [ValidationResult] = [validationResultPassedAcceptanceRule,
                                                    validationResultFailedAcceptanceRule]
        let result = try CertificateResult(certificate: .mock(), result: validationResult)
        let sut = configureSut(result: result)
        verifyView(view: sut.view, height: 2000)
    }
    
    func test_1_rule_open() throws {
        let validationResult: [ValidationResult] = [validationResultPassedAcceptanceRule,
                                                  validationResultOpenAcceptanceRule]
        let result = try CertificateResult(certificate: .mock(), result: validationResult)
        let sut = configureSut(result: result)
        verifyView(view: sut.view, height: 2000)
    }
}
