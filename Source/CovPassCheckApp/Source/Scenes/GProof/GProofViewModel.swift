//
//  GProofViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import CovPassCommon
import CovPassUI
import PromiseKit
import Scanner

private enum Constants {
    enum Keys {
        static let accessibility_scan_result_announce_2G = "accessibility_scan_result_announce_2G".localized
        static let accessibility_scan_result_closing_announce_2G = "accessibility_scan_result_closing_announce_2G".localized
        static let result_2G_title = "result_2G_title".localized
        static let result_2G_close = "result_2G_close".localized
        static let result_2G_footnote = "result_2G_footnote".localized
        static let result_2G_button_scan_test = "result_2G_button_scan_test".localized
        static let result_2G_button_scan_gproof = "result_2G_button_scan_gproof".localized
        static let result_2G_button_retry = "result_2G_button_retry".localized
        static let result_2G_button_startover = "result_2G_button_startover".localized
        static let validation_check_popup_valid_pcr_test_message = "validation_check_popup_valid_pcr_test_message".localized
        static let result_2G_gproof_empty = "result_2G_gproof_empty".localized
        static let result_2G_gproof_valid = "result_2G_gproof_valid".localized
        static let result_2G_gproof_valid_boosted = "result_2G_booster_valid".localized
        static let result_2G_gproof_invalid = "result_2G_gproof_invalid".localized
        static let result_2G_test_empty = "result_2G_test_empty".localized
        static let result_2G_test_invalid = "result_2G_test_invalid".localized
        static let validation_check_popup_test_title = "validation_check_popup_test_title".localized
        static let validation_check_popup_test_date_of_birth = "validation_check_popup_test_date_of_birth".localized
        static let result_2G_invalid_subtitle = "result_2G_invalid_subtitle".localized
        static let result_2G_empty_subtitle = "result_2G_empty_subtitle".localized
    }
    enum Images {
        static let detailStatusFull = UIImage.detailStatusFull
        static let detailStatusFailed = UIImage.detailStatusFailed
        static let detailStatusFullEmpty = UIImage.detailStatusFullEmpty
        static let detailStatusTestEmpty = UIImage.detailStatusTestEmpty
        static let detailStatusTest = UIImage.detailStatusTest
        static let iconCardInverse = UIImage.iconCardInverse
        static let chevronRight = UIImage.FieldRight
    }
}

class GProofViewModel: GProofViewModelProtocol {
    var title: String { Constants.Keys.result_2G_title}
    var checkIdMessage: String { Constants.Keys.validation_check_popup_valid_pcr_test_message}
    var footnote: String { Constants.Keys.result_2G_footnote}
    var buttonScanTest: String { Constants.Keys.result_2G_button_scan_test}
    var buttonRetry: String { Constants.Keys.result_2G_button_retry}
    var buttonStartOver: String { Constants.Keys.result_2G_button_startover}
    var buttonScan2G: String { Constants.Keys.result_2G_button_scan_gproof}
    var accessibilityResultAnnounce: String { Constants.Keys.accessibility_scan_result_announce_2G}
    var accessibilityResultAnnounceClose: String { Constants.Keys.accessibility_scan_result_closing_announce_2G}
    var resultGProofImage: UIImage {
        switch gProofResultViewModel {
        case is ErrorResultViewModel: return Constants.Images.detailStatusFailed
        case is VaccinationResultViewModel, is RecoveryResultViewModel: return Constants.Images.detailStatusFull
        case is ErrorResultViewModel: return Constants.Images.detailStatusFailed
        default: return Constants.Images.detailStatusFullEmpty
        }
    }
    var resultGProofTitle: String {
        switch gProofResultViewModel {
        case is ErrorResultViewModel: return Constants.Keys.result_2G_gproof_invalid
        case is VaccinationResultViewModel, is RecoveryResultViewModel:
            return initialTokenIsBoosted ? Constants.Keys.result_2G_gproof_valid_boosted : Constants.Keys.result_2G_gproof_valid
        default: return Constants.Keys.result_2G_gproof_empty
        }
    }
    var resultGProofSubtitle: String? {
        switch gProofResultViewModel {
        case is ErrorResultViewModel: return Constants.Keys.result_2G_invalid_subtitle
        case is VaccinationResultViewModel, is RecoveryResultViewModel: return nil
        default: return Constants.Keys.result_2G_empty_subtitle
        }
    }
    var resultGProofLinkImage: UIImage? {
        switch gProofResultViewModel {
        case is ErrorResultViewModel: return Constants.Images.chevronRight
        case is VaccinationResultViewModel, is RecoveryResultViewModel: return nil
        default: return nil
        }
    }
    var resultGProofFooter: String? { nil }
    var resultTestImage: UIImage {
        switch testResultViewModel {
        case is ErrorResultViewModel: return Constants.Images.detailStatusFailed
        case is TestResultViewModel: return Constants.Images.detailStatusTest
        case is ErrorResultViewModel: return Constants.Images.detailStatusFailed
        default: return Constants.Images.detailStatusTestEmpty
        }
    }
    var resultTestTitle: String {
        switch testResultViewModel {
        case is ErrorResultViewModel: return Constants.Keys.result_2G_test_invalid
        case is TestResultViewModel:
            guard let sc = testResultViewModel?.certificate?.hcert.dgc.t?.first?.sc else {
                return ""
            }
            let diffComponents = Calendar.current.dateComponents([.hour], from: sc, to: Date())
            return String(format: Constants.Keys.validation_check_popup_test_title, diffComponents.hour ?? 0)
        default: return Constants.Keys.result_2G_test_empty
        }
    }
    var resultTestSubtitle: String? {
        switch testResultViewModel {
        case is ErrorResultViewModel: return Constants.Keys.result_2G_invalid_subtitle
        case is TestResultViewModel: return nil
        default: return Constants.Keys.result_2G_empty_subtitle
        }
    }
    var resultTestLinkImage: UIImage? {
        switch testResultViewModel {
        case is ErrorResultViewModel: return Constants.Images.chevronRight
        case is TestResultViewModel: return nil
        default: return nil
        }
    }
    var resultTestFooter: String? { nil }
    var resultPersonIcon: UIImage {
        return Constants.Images.iconCardInverse
    }
    var resultPersonTitle: String? {
        return gProofResultViewModel?.certificate?.hcert.dgc.nam.fullName ?? testResultViewModel?.certificate?.hcert.dgc.nam.fullName
    }
    var resultPersonSubtitle: String? {
        return gProofResultViewModel?.certificate?.hcert.dgc.nam.fullNameTransliterated ?? testResultViewModel?.certificate?.hcert.dgc.nam.fullNameTransliterated
    }
    var resultPersonFooter: String? {
        let digitalGreenCert = gProofResultViewModel?.certificate?.hcert.dgc ?? testResultViewModel?.certificate?.hcert.dgc
        guard let dgc = digitalGreenCert else {
            return nil
        }
        return String(format: Constants.Keys.validation_check_popup_test_date_of_birth, DateUtils.displayDateOfBirth(dgc))
    }
    var testResultViewIsHidden: Bool {
        initialTokenIsBoosted && !(gProofResultViewModel is ErrorResultViewModel)
    }
    var buttonScanTestIsHidden: Bool {
        if testResultViewModel != nil || someIsFailed || testResultViewIsHidden {
            return true
        }
        return false
    }
    var buttonScan2GIsHidden: Bool {
        if gProofResultViewModel != nil || someIsFailed {
            return true
        }
        return false
    }
    var buttonRetryIsHidden: Bool { areBothScanned && someIsFailed ? false : true }
    var buttonStartOverIsHidden: Bool { false }
    var onlyOneIsScannedAndThisFailed: Bool { !areBothScanned && someIsFailed }
    var someIsFailed: Bool { testResultViewModel is ErrorResultViewModel || gProofResultViewModel is ErrorResultViewModel  }
    var areBothScanned: Bool { gProofResultViewModel != nil && testResultViewModel != nil}
    var gProofResultViewModel: ValidationResultViewModel? = nil
    var testResultViewModel: ValidationResultViewModel? = nil
    let router: GProofRouterProtocol
    internal var delegate: ViewModelDelegate?
    private var initialToken: CBORWebToken?
    private var initialTokenIsBoosted: Bool
    private let repository: VaccinationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol
    private let error: Error? = nil
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private var lastTriedCertType: CertType? = nil
    private var userDefaults: Persistence
    private var boosterAsTest: Bool

    init(initialToken: CBORWebToken,
         router: GProofRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol,
         userDefaults: Persistence,
         boosterAsTest: Bool) {
        self.repository = repository
        self.certLogic = certLogic
        self.userDefaults = userDefaults
        self.router = router
        self.initialToken = initialToken
        self.boosterAsTest = boosterAsTest
        initialTokenIsBoosted = initialToken.hcert.dgc.isVaccinationBoosted && boosterAsTest
        lastTriedCertType = initialToken.isTest ? .test : .vaccination
        _ = self.setResultViewModel(newToken: initialToken)
        self.delegate?.viewModelDidUpdate()
    }
    
    private func startQRCodeValidation(for scanType: ScanType) {
        firstly {
            router.scanQRCode()
        }
        .map {
            try self.payloadFromScannerResult($0)
        }
        .then {
            self.repository.checkCertificate($0)
        }
        .then {
            try self.preventSettingSameQRCode($0)
        }
        .then {
            self.setResultViewModel(newToken: $0)
        }
        .then {
            self.checkIfSamePerson()
        }
        .done {
            self.delegate?.viewModelDidUpdate()
        }
        .catch { error in
            if (error as? QRCodeError) == .qrCodeExists {
                self.router.showError(error: error)
            } else if (error as? ScanError) == .badOutput {
                let showCert = self.lastTriedCertType == .test ? self.testResultViewModel?.certificate : self.gProofResultViewModel?.certificate
                self.router.showCertificate(showCert,
                                            _2GContext: true,
                                            userDefaults: self.userDefaults)
            } else {
                _ = self.setResultViewModel(newToken: nil)
                self.delegate?.viewModelDidUpdate()
            }
        }
    }
    
    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case let .success(payload):
            return payload
        case let .failure(error):
            throw error
        }
    }
    
    private func preventSettingSameQRCode(_ newToken: CBORWebToken) throws -> Promise<CBORWebToken> {
        let newTokenData = try jsonEncoder.encode(newToken)
        
        if initialToken?.isTest ?? false && newToken.isTest {
            throw QRCodeError.qrCodeExists
        } else if (initialToken?.isRecovery ?? false || initialToken?.isVaccination ?? false) && (newToken.isVaccination || newToken.isRecovery) {
            throw QRCodeError.qrCodeExists
        }
        
        if let gProofToken = self.gProofResultViewModel?.certificate,
           let gProofTokenQrCode = try? jsonEncoder.encode(gProofToken),
           newTokenData == gProofTokenQrCode  {
            throw QRCodeError.qrCodeExists
        }
        
        if let testToken = self.testResultViewModel?.certificate,
           let testProofProofTokenQrCode = try? jsonEncoder.encode(testToken),
           newTokenData == testProofProofTokenQrCode {
            throw QRCodeError.qrCodeExists
        }

        return .value(newToken)
    }
    
    private func setResultViewModel(newToken: CBORWebToken?) -> Promise<Void> {
        let validationResultViewModel = ValidationResultFactory.createViewModel(router: router,
                                                                                repository: repository,
                                                                                certificate: newToken,
                                                                                error: error,
                                                                                type: userDefaults.selectedLogicType,
                                                                                certLogic: certLogic,
                                                                                _2GContext: true,
                                                                                userDefaults: userDefaults)
        switch validationResultViewModel {
        case is VaccinationResultViewModel, is RecoveryResultViewModel: self.gProofResultViewModel = validationResultViewModel
        case is TestResultViewModel: self.testResultViewModel = validationResultViewModel
        case is ErrorResultViewModel:
            if lastTriedCertType == .test {
                self.testResultViewModel = validationResultViewModel
            } else {
                self.gProofResultViewModel = validationResultViewModel
            }
        default:
            break
        }
        initialTokenIsBoosted = newToken?.hcert.dgc.isVaccinationBoosted ?? false && boosterAsTest
        if initialToken == nil {
            initialToken = newToken
        }
        return .value
    }
    
    private func checkIfSamePerson() -> Promise<Void> {
        guard areBothScanned else {
            return .value
        }
        guard gProofResultViewModel?.certificate?.hcert.dgc.nam.fullNameTransliterated != testResultViewModel?.certificate?.hcert.dgc.nam.fullNameTransliterated || gProofResultViewModel?.certificate?.hcert.dgc.dob != testResultViewModel?.certificate?.hcert.dgc.dob  else {
            return .value
        }
        guard let gProofToken = gProofResultViewModel?.certificate else {
            return .value
        }
        guard let testProofToken = testResultViewModel?.certificate else {
            return .value
        }
        
        _ = firstly {
            router.showDifferentPerson(gProofToken: gProofToken,
                                       testProofToken: testProofToken)
        }
        .done {
            switch $0 {
            case .startover: self.startover()
            case .retry: self.retry()
            case.cancel: break
            }
        }
        .cauterize()
        
        return .value
    }
    
    func scanTest() {
        lastTriedCertType = .test
        startQRCodeValidation(for: ._2G)
    }
    
    func scan2GProof() {
        lastTriedCertType = .vaccination
        startQRCodeValidation(for: ._2G)
    }
    
    func retry() {
        if lastTriedCertType == .test {
            testResultViewModel = nil
        } else {
            gProofResultViewModel = nil
        }
        delegate?.viewModelDidUpdate()
        startQRCodeValidation(for: ._2G)
    }
    
    func startover() {
        testResultViewModel = nil
        gProofResultViewModel = nil
        initialToken = nil
        delegate?.viewModelDidUpdate()
        startQRCodeValidation(for: ._2G)
    }
    
    func cancel() {
        router.sceneCoordinator.dimiss(animated: true)
    }
    
    func showResultGProof() {
        router.showCertificate(gProofResultViewModel?.certificate,
                               _2GContext: true,
                               userDefaults: userDefaults)
    }
    
    func showResultTestProof() {
        router.showCertificate(testResultViewModel?.certificate,
                               _2GContext: true,
                               userDefaults: userDefaults)
    }
}
