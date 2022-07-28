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
    
    let (_, resolver) = Promise<ExtendedCBORWebToken>.pending()
    var persistence: UserDefaultsPersistence!
    
    override func setUpWithError() throws {
        persistence = UserDefaultsPersistence()
    }
    
    override func tearDown() {
        persistence = nil
    }

    func configureView(error: ValidationResultError?,
                       token: ExtendedCBORWebToken?,
                       _2GContext: Bool,
                       buttonHidden: Bool,
                       expertMode: Bool? = nil,
                       hideCountdown: Bool = true
    ) -> UIView {
        let cborWebToken = token?.vaccinationCertificate
        var vm: ValidationResultViewModel!
        if let expertMode = expertMode, expertMode {
            persistence.revocationExpertMode = true
        } else {
            try? persistence.delete(UserDefaults.keyRevocationExpertMode)
        }
        if let error = error {
            vm = ErrorResultViewModel(resolvable: resolver,
                                      router: ValidationResultRouterMock(),
                                      repository: VaccinationRepositoryMock(),
                                      certificate: nil,
                                      error: error,
                                      _2GContext: _2GContext,
                                      userDefaults: persistence,
                                      revocationKeyFilename: "")
        } else {
            guard let cborWebToken = cborWebToken else {
                return UIView()
            }
            let countdownTimerModel = CountdownTimerModelMock()
            countdownTimerModel.hideCountdown = hideCountdown

            if cborWebToken.isVaccination {
                vm = VaccinationResultViewModel(resolvable: resolver,
                                                router: ValidationResultRouterMock(),
                                                repository: VaccinationRepositoryMock(),
                                                certificate: token,
                                                _2GContext: _2GContext,
                                                userDefaults: persistence,
                                                revocationKeyFilename: "",
                                                countdownTimerModel: countdownTimerModel)
            } else if cborWebToken.isRecovery {
                vm = RecoveryResultViewModel(resolvable: resolver,
                                             router: ValidationResultRouterMock(),
                                             repository: VaccinationRepositoryMock(),
                                             certificate: token,
                                             _2GContext: _2GContext,
                                             userDefaults: persistence,
                                             revocationKeyFilename: "",
                                             countdownTimerModel: countdownTimerModel)
            } else if cborWebToken.isTest {
                vm = TestResultViewModel(resolvable: resolver,
                                         router: ValidationResultRouterMock(),
                                         repository: VaccinationRepositoryMock(),
                                         certificate: token,
                                         _2GContext: _2GContext,
                                         userDefaults: persistence,
                                         revocationKeyFilename: "",
                                         countdownTimerModel: countdownTimerModel)
            }
        }
        vm.buttonHidden = buttonHidden
        return ValidationResultViewController(viewModel: vm).view
    }
    
    func testValidationResultViewControllerWithTechnicalError() {
        let view = configureView(error: .technical, token: nil, _2GContext: false, buttonHidden: false)
        verifyView(view: view, height: 900)
    }

    func testValidationResultViewControllerWithFunctionalError() {
        let view = configureView(error: .functional, token: nil, _2GContext: false, buttonHidden: false)
        verifyView(view: view, height: 900)
    }
    
    func testValidationResultViewControllerWithTechnicalError2GContext() {
        let view = configureView(error: .technical, token: nil, _2GContext: true, buttonHidden: false)
        verifyView(view: view, height: 900)

    }
    
    func testValidationResultViewControllerWithFunctionalError2GContext() {
        let view = configureView(error: .functional, token: nil, _2GContext: true, buttonHidden: false)
        verifyView(view: view, height: 900)
    }
    
    func testValidationResultViewControllerWithFunctionalError2GContextButtonHidden() {
        let view = configureView(error: .functional, token: nil, _2GContext: true, buttonHidden: true)
        verifyView(view: view, height: 900)
    }
    
    func testSuccessVaccination() {
        let token = ExtendedCBORWebToken(
            vaccinationCertificate: CBORWebToken.mockVaccinationCertificate,
            vaccinationQRCodeData: "")
        let view = configureView(error: nil, token: token, _2GContext: true, buttonHidden: true)
        verifyView(view: view, height: 900)
    }

    func testSuccessVaccination_with_countdown() {
        let token = ExtendedCBORWebToken(
            vaccinationCertificate: CBORWebToken.mockVaccinationCertificate,
            vaccinationQRCodeData: "")
        let view = configureView(error: nil, token: token, _2GContext: true, buttonHidden: true, hideCountdown: false)
        verifyView(view: view, height: 900)
    }
    
    func testSuccessRecovery() {
        let token = ExtendedCBORWebToken(
            vaccinationCertificate: CBORWebToken.mockVaccinationCertificate,
            vaccinationQRCodeData: "")
        let view = configureView(error: nil, token: token, _2GContext: true, buttonHidden: true)
        verifyView(view: view, height: 900)
    }

    func testSuccessRecovery_with_countdown() {
        let token = ExtendedCBORWebToken(
            vaccinationCertificate: CBORWebToken.mockVaccinationCertificate,
            vaccinationQRCodeData: "")
        let view = configureView(error: nil, token: token, _2GContext: true, buttonHidden: true, hideCountdown: false)
        verifyView(view: view, height: 900)
    }
    
    func testSuccessRecoveryExpertMode() {
        let token = ExtendedCBORWebToken(
            vaccinationCertificate: CBORWebToken.mockVaccinationCertificate,
            vaccinationQRCodeData: "")
        let view = configureView(error: nil, token: token, _2GContext: false, buttonHidden: false, expertMode: true)
        verifyView(view: view, height: 900)
    }
    
    func testSuccessVaccinationExpertMode() {
        let token = ExtendedCBORWebToken(
            vaccinationCertificate: CBORWebToken.mockVaccinationCertificate,
            vaccinationQRCodeData: "")
        let view = configureView(error: nil, token: token, _2GContext: false, buttonHidden: false, expertMode: true)
        verifyView(view: view, height: 900)
    }
    
    func testErrorFunctionalExpertMode() {
        let view = configureView(error: .functional, token: nil, _2GContext: false, buttonHidden: false, expertMode: true)
        verifyView(view: view, height: 900)
    }
}
