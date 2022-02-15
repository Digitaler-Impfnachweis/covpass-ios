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
    static let footnoteSignal = "*"
    enum Keys {
        static let result_2G_gproof_invalid = "result_2G_gproof_invalid".localized
        static let accessibility_scan_result_announce_2G = "accessibility_scan_result_announce_2G".localized
        static let accessibility_scan_result_closing_announce_2G = "accessibility_scan_result_closing_announce_2G".localized
        static let result_2G_title = "result_2G_title".localized
        static let validation_check_popup_valid_pcr_test_message = "validation_check_popup_valid_pcr_test_message".localized
        static let result_2G__3rd_footnote = "result_2G__3rd_footnote".localized
        static let result_2G__3rd_button = "result_2G__3rd_button".localized
        static let result_2G_button_retry = "result_2G_button_retry".localized
        static let result_2G_button_startover = "result_2G_button_startover".localized
        static let validation_check_popup_test_date_of_birth = "validation_check_popup_test_date_of_birth".localized
    }
    enum Images {
        static let iconCardInverse = UIImage.iconCardInverse
        static let detailStatusFull = UIImage.detailStatusFull
        static let detailStatusFailed = UIImage.detailStatusFailed
        static let detailStatusFullEmpty = UIImage.detailStatusFullEmpty
        static let detailStatusTestEmpty = UIImage.detailStatusTestEmpty
        static let detailStatusTest = UIImage.detailStatusTest
        static let chevronRight = UIImage.FieldRight
    }
}

class GProofViewModel: GProofViewModelProtocol {
    var title: String { Constants.Keys.result_2G_title}
    var checkIdMessage: String { Constants.Keys.validation_check_popup_valid_pcr_test_message}
    var footnote: String { Constants.Keys.result_2G__3rd_footnote}
    var buttonScanNextTitle: String { Constants.Keys.result_2G__3rd_button}
    var buttonRetry: String { Constants.Keys.result_2G_button_retry}
    var buttonStartOver: String { Constants.Keys.result_2G_button_startover}
    var accessibilityResultAnnounce: String { Constants.Keys.accessibility_scan_result_announce_2G}
    var accessibilityResultAnnounceClose: String { Constants.Keys.accessibility_scan_result_closing_announce_2G}
    var firstResultImage: UIImage { firstResult.image }
    var firstResultTitle: String { firstResult.title(theOtherResultVM: secondResult, initialTokenIsBoosted: initialTokenIsBoosted) }
    var firstResultSubtitle: String? { firstResult.subtitle }
    var firstResultLinkImage: UIImage? { firstResult.linkImage }
    var firstResultFooterText: String? { nil }
    var secondResultImage: UIImage { secondResult.image }
    var secondResultTitle: String { secondResult.title(theOtherResultVM: firstResult, initialTokenIsBoosted: initialTokenIsBoosted) }
    var seconResultSubtitle: String? { secondResult.subtitle}
    var seconResultLinkImage: UIImage? { secondResult.linkImage }
    var seconResultFooterText: String? { nil }
    var resultPersonIcon: UIImage { Constants.Images.iconCardInverse }
    var resultPersonTitle: String? { firstResult?.certificate?.hcert.dgc.nam.fullName ?? secondResult?.certificate?.hcert.dgc.nam.fullName }
    var resultPersonSubtitle: String? { firstResult?.certificate?.hcert.dgc.nam.fullNameTransliterated ?? secondResult?.certificate?.hcert.dgc.nam.fullNameTransliterated }
    var resultPersonFooter: String? {
        let digitalGreenCert = firstResult?.certificate?.hcert.dgc ?? secondResult?.certificate?.hcert.dgc
        guard let dgc = digitalGreenCert else {
            return nil
        }
        return String(format: Constants.Keys.validation_check_popup_test_date_of_birth, DateUtils.displayDateOfBirth(dgc))
    }
    var seconResultViewIsHidden: Bool {
        initialTokenIsBoosted && !(firstResult is ErrorResultViewModel)
    }
    var scanNextButtonIsHidden: Bool {
        if secondResult != nil || someIsFailed || seconResultViewIsHidden {
            return true
        }
        return false
    }
    var buttonRetryIsHidden: Bool { areBothScanned && someIsFailed ? false : true }
    var buttonStartOverIsHidden: Bool { false }
    var pageFooterIsHidden: Bool { seconResultViewIsHidden ||
        !firstResultTitle.contains(Constants.footnoteSignal)  &&
        !secondResultTitle.contains(Constants.footnoteSignal) }
    var onlyOneIsScannedAndThisFailed: Bool { !areBothScanned && someIsFailed }
    var someIsFailed: Bool { secondResult is ErrorResultViewModel || firstResult is ErrorResultViewModel  }
    var areBothScanned: Bool { firstResult != nil && secondResult != nil}
    var firstResult: ValidationResultViewModel? = nil
    var secondResult: ValidationResultViewModel? = nil
    let router: GProofRouterProtocol
    internal var delegate: ViewModelDelegate?
    private var initialTokenIsBoosted: Bool = false
    private let repository: VaccinationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol
    private let error: Error? = nil
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private var lastTriedCertType: CertType? = nil
    private var userDefaults: Persistence
    private var boosterAsTest: Bool
    private var resolvable: Resolver<CBORWebToken>
    init(resolvable: Resolver<CBORWebToken>,
         initialToken: CBORWebToken,
         router: GProofRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol,
         userDefaults: Persistence,
         boosterAsTest: Bool) {
        self.resolvable = resolvable
        self.repository = repository
        self.certLogic = certLogic
        self.userDefaults = userDefaults
        self.router = router
        self.boosterAsTest = boosterAsTest
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
        .cancelled {
            if self.secondResult == nil && self.firstResult == nil {
                self.router.sceneCoordinator.dimiss(animated: true)
            }
        }
        .catch { error in
            if (error as? QRCodeError) == .qrCodeExists {
                self.router.showError(error: error)
            } else if (error as? ScanError) == .badOutput || (error as? Base45CodingError) == .base45Decoding {
                let showCert = self.lastTriedCertType == .test ? self.secondResult?.certificate : self.firstResult?.certificate
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
        
        guard firstResult?.certificate?.certType != newToken.certType else {
            throw QRCodeError.qrCodeExists
        }
        
        return .value(newToken)
    }
    
    private func setResultViewModel(newToken: CBORWebToken?) -> Promise<Void> {
        let validationResultViewModel = ValidationResultFactory.createViewModel(resolvable: resolvable,
                                                                                router: router,
                                                                                repository: repository,
                                                                                certificate: newToken,
                                                                                error: error,
                                                                                type: userDefaults.selectedLogicType,
                                                                                certLogic: certLogic,
                                                                                _2GContext: true,
                                                                                userDefaults: userDefaults)
        initialTokenIsBoosted = newToken?.hcert.dgc.isVaccinationBoosted ?? false && boosterAsTest
        
        if lastTriedCertType == nil || initialTokenIsBoosted {
            self.firstResult = validationResultViewModel
        } else {
            self.secondResult = validationResultViewModel
        }
        return .value
    }
    
    private func checkIfSamePerson() -> Promise<Void> {
        guard !initialTokenIsBoosted else {
            return .value
        }
        guard areBothScanned else {
            return .value
        }
        guard certificateAndTestNameOrDateOfBirthAreNotMatching else {
            return .value
        }
        guard let firstResultCert = firstResult?.certificate, !(firstResult is ErrorResultViewModel) else {
            return .value
        }
        guard let secondResultCert = secondResult?.certificate, !(secondResult is ErrorResultViewModel) else {
            return .value
        }
        
        _ = firstly {
            router.showDifferentPerson(firstResultCert: firstResultCert,
                                       scondResultCert: secondResultCert)
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
    
    private var certificateAndTestNameOrDateOfBirthAreNotMatching: Bool {
        firstResult?.certificate?.hcert.dgc != secondResult?.certificate?.hcert.dgc
    }
    
    func scanNext() {
        lastTriedCertType = .test
        startQRCodeValidation(for: ._2G)
    }
    
    func retry() {
        if lastTriedCertType == .test {
            secondResult = nil
        } else {
            firstResult = nil
        }
        delegate?.viewModelDidUpdate()
        startQRCodeValidation(for: ._2G)
    }
    
    func startover() {
        secondResult = nil
        firstResult = nil
        lastTriedCertType = nil
        delegate?.viewModelDidUpdate()
        startQRCodeValidation(for: ._2G)
    }
    
    func cancel() {
        router.sceneCoordinator.dimiss(animated: true)
    }
    
    func showFirstCardResult() {
        router.showCertificate(firstResult?.certificate,
                               _2GContext: true,
                               userDefaults: userDefaults)
    }
    
    func showSecondCardResult() {
        router.showCertificate(secondResult?.certificate,
                               _2GContext: true,
                               userDefaults: userDefaults)
    }
    

    

    

    
    
    
    
    
    
    
    

    
}




