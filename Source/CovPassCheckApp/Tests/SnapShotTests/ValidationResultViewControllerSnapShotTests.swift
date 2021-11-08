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

class ValidationResultViewControllerSnapShotTests: BaseSnapShotTests {

    func testValidationResultViewControllerWithTechnicalError() {
        let vm = ErrorResultViewModel(router: ValidationResultRouterMock(), repository: VaccinationRepositoryMock(), certificate: nil, error: ValidationResultError.technical)
        let vc = ValidationResultViewController(viewModel: vm)
        verifyView(vc: vc)
    }

    func testValidationResultViewControllerWithFunctionalError() {
        let vm = ErrorResultViewModel(router: ValidationResultRouterMock(), repository: VaccinationRepositoryMock(), certificate: nil, error: ValidationResultError.functional)
        let vc = ValidationResultViewController(viewModel: vm)
        verifyView(vc: vc)
    }

}
