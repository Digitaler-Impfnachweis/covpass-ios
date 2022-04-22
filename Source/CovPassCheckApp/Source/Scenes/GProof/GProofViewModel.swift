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
    var resultPersonTitle: String? {
        firstResult?.certificate?.vaccinationCertificate.hcert.dgc.nam.fullName ??
        secondResult?.certificate?.vaccinationCertificate.hcert.dgc.nam.fullName
    }
    var resultPersonSubtitle: String? {
        firstResult?.certificate?.vaccinationCertificate.hcert.dgc.nam.fullNameTransliterated ??
        secondResult?.certificate?.vaccinationCertificate.hcert.dgc.nam.fullNameTransliterated
    }
    var resultPersonFooter: String? {
        let digitalGreenCert = firstResult?.certificate?.vaccinationCertificate.hcert.dgc ?? secondResult?.certificate?.vaccinationCertificate.hcert.dgc
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
    var firstIsFailedTechnicalReason: Bool { (firstResult is ErrorResultViewModel) }
    var secondIsFailedTechnicalReason: Bool { (secondResult is ErrorResultViewModel) }
    let router: GProofRouterProtocol
    internal var delegate: ViewModelDelegate?
    private var initialTokenIsBoosted: Bool = false
    private var error: Error?
    private let repository: VaccinationRepositoryProtocol
    private let revocationRepository: CertificateRevocationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private var lastTriedCertType: CertType? = nil
    private var userDefaults: Persistence
    private var boosterAsTest: Bool
    private var resolvable: Resolver<ExtendedCBORWebToken>
    private var isFirstScan = true
    init(resolvable: Resolver<ExtendedCBORWebToken>,
         router: GProofRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         revocationRepository: CertificateRevocationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol,
         userDefaults: Persistence,
         boosterAsTest: Bool) {
        self.resolvable = resolvable
        self.repository = repository
        self.revocationRepository = revocationRepository
        self.certLogic = certLogic
        self.userDefaults = userDefaults
        self.router = router
        self.boosterAsTest = boosterAsTest
    }
    
    
    func scanQRCode() {
        var tmpToken: ExtendedCBORWebToken?
        firstly {
            router.scanQRCode()
        }
        .then {
            ParseCertificateUseCase(scanResult: $0,
                                    vaccinationRepository: self.repository).execute()
        }
        .then { token -> Promise<ExtendedCBORWebToken> in
            tmpToken = token
            return ValidateCertificateUseCase(token: token,
                                              revocationRepository: CertificateRevocationRepository()!,
                                              certLogic: self.certLogic,
                                              persistence: self.userDefaults).execute()
        }
        .cancelled {
            if self.isFirstScan {
                self.router.sceneCoordinator.dimiss(animated: true)
            }
        }
        .done {
            self.validationToken(token: $0)
        }
        .catch { error in
            self.errorHandling(error, token: tmpToken)
        }
    }
    
    private func validationToken(token: ExtendedCBORWebToken) {
        firstly {
            try self.preventSettingSameQRCode(token)
        }
        .then {
            self.setResultViewModel(error: nil, newToken: $0)
        }
        .then {
            self.checkIfSamePerson()
        }
        .done {
            self.delegate?.viewModelDidUpdate()
        }
        .catch {
            self.errorHandling($0, token: token)
        }
    }
    
    private func errorHandling(_ error: Error, token: ExtendedCBORWebToken?) {
        self.error = error
        if (error as? QRCodeError) == .qrCodeExists {
            router.showError(error: error)
        } else if isFirstScan && (error is ScanError || error is Base45CodingError || error is CertificateError) {
            showErorResultPage(error: error, token: token)
            setResultViewModel(error: error, newToken: token).cauterize()
        } else {
            setResultViewModel(error: error, newToken: token).cauterize()
        }
    }
    
    private func showErorResultPage(error: Error, token: ExtendedCBORWebToken?) {
        let shouldShowStartOverButton = !isFirstScan
        router.showCertificate(token,
                               _2GContext: true,
                               error: error,
                               userDefaults: userDefaults,
                               buttonHidden: shouldShowStartOverButton)
            .done { token in
                self.validationToken(token: token)
            }
            .cancelled {
                self.resultPageCancelled()
            }.cauterize()
    }
    
    private func resultPageCancelled() {
        if isFirstScan {
            router.sceneCoordinator.dimiss(animated: true)
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
    
    private func preventSettingSameQRCode(_ newToken: ExtendedCBORWebToken) throws -> Promise<ExtendedCBORWebToken> {
        let certTypeIsNotAlreadyScanned = firstResult?.certificate?.vaccinationCertificate.certType != newToken.vaccinationCertificate.certType
        let exceptionBoosterWillReplaceCurrent = (newToken.vaccinationCertificate.hcert.dgc.isVaccinationBoosted && boosterAsTest)
        guard certTypeIsNotAlreadyScanned || exceptionBoosterWillReplaceCurrent else {
            throw QRCodeError.qrCodeExists
        }
        return .value(newToken)
    }
    
    private func setResultViewModel(error: Error?, newToken: ExtendedCBORWebToken?) -> Promise<Void> {
        let validationResultViewModel = ValidationResultFactory.createViewModel(resolvable: resolvable,
                                                                                router: router,
                                                                                repository: repository,
                                                                                certificate: newToken,
                                                                                error: error,
                                                                                _2GContext: true,
                                                                                userDefaults: userDefaults)
        initialTokenIsBoosted = newToken?.vaccinationCertificate.hcert.dgc.isVaccinationBoosted ?? false && boosterAsTest
        
        if lastTriedCertType == nil || initialTokenIsBoosted {
            firstResult = validationResultViewModel
        } else {
            secondResult = validationResultViewModel
        }
        delegate?.viewModelDidUpdate()
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
            router.showDifferentPerson(firstResultCert: firstResultCert.vaccinationCertificate,
                                       scondResultCert: secondResultCert.vaccinationCertificate)
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
        firstResult?.certificate?.vaccinationCertificate.hcert.dgc !=
        secondResult?.certificate?.vaccinationCertificate.hcert.dgc
    }
    
    func scanNext() {
        isFirstScan = false
        lastTriedCertType = .test
        scanQRCode()
    }
    
    func retry() {
        isFirstScan = false
        if lastTriedCertType == .test {
            secondResult = nil
        } else {
            firstResult = nil
        }
        delegate?.viewModelDidUpdate()
        scanQRCode()
    }
    
    func startover() {
        isFirstScan = true
        secondResult = nil
        firstResult = nil
        lastTriedCertType = nil
        delegate?.viewModelDidUpdate()
        scanQRCode()
    }
    
    func cancel() {
        router.sceneCoordinator.dimiss(animated: true)
    }
    
    func showFirstCardResult() {
        router
            .showCertificate(firstResult?.certificate,
                             _2GContext: true,
                             error: error,
                             userDefaults: userDefaults,
                             buttonHidden: true)
            .cauterize()
    }
    
    func showSecondCardResult() {
        router
            .showCertificate(secondResult?.certificate,
                             _2GContext: true,
                             error: error,
                             userDefaults: userDefaults,
                             buttonHidden: true)
            .cauterize()
    }
}




