//
//  ValidationResultViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import XCTest
import CovPassUI
import PromiseKit
import CovPassCommon

class ValidationResultViewControllerSnapShotTests: BaseSnapShotTests {
    
    func testValidationResultViewControllerWithTechnicalError() {
        let vm = ErrorResultViewModel(router: ValidationResultRouterMock(),
                                      repository: VaccinationRepositoryMock(),
                                      certificate: nil,
                                      error: ValidationResultError.technical,
                                      _2GContext: false,
                                      userDefaults: UserDefaultsPersistence())
        let vc = ValidationResultViewController(viewModel: vm)
        verifyView(vc: vc)
    }

    func testValidationResultViewControllerWithFunctionalError() {
        let vm = ErrorResultViewModel(router: ValidationResultRouterMock(),
                                      repository: VaccinationRepositoryMock(),
                                      certificate: nil,
                                      error: ValidationResultError.functional,
                                      _2GContext: false,
                                      userDefaults: UserDefaultsPersistence())
        let vc = ValidationResultViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testValidationResultViewControllerWithTechnicalError2GContext() {
        let vm = ErrorResultViewModel(router: ValidationResultRouterMock(),
                                      repository: VaccinationRepositoryMock(),
                                      certificate: nil,
                                      error: ValidationResultError.technical,
                                      _2GContext: true,
                                      userDefaults: UserDefaultsPersistence())
        let vc = ValidationResultViewController(viewModel: vm)
        verifyView(vc: vc)
    }

    func testValidationResultViewControllerWithFunctionalError2GContext() {
        let vm = ErrorResultViewModel(router: ValidationResultRouterMock(),
                                      repository: VaccinationRepositoryMock(),
                                      certificate: nil,
                                      error: ValidationResultError.functional,
                                      _2GContext: true,
                                      userDefaults: UserDefaultsPersistence())
        let vc = ValidationResultViewController(viewModel: vm)
        verifyView(vc: vc)
    }

}
