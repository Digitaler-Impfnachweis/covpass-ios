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
import CertLogic

public struct GProofValidationResult {
    var token: ExtendedCBORWebToken?
    var error: Error?
    var result: [CertLogic.ValidationResult]?
}

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
    var isLoading: Bool = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }
    var personStackIsHidden: Bool { firstIsFailedTechnicalReason || firstResult == nil }
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
        firstToken?.vaccinationCertificate.hcert.dgc.nam.fullName ??
        secondToken?.vaccinationCertificate.hcert.dgc.nam.fullName
    }
    var resultPersonSubtitle: String? {
        firstToken?.vaccinationCertificate.hcert.dgc.nam.fullNameTransliterated ??
        secondToken?.vaccinationCertificate.hcert.dgc.nam.fullNameTransliterated
    }
    var resultPersonFooter: String? {
        let digitalGreenCert = firstToken?.vaccinationCertificate.hcert.dgc ?? secondToken?.vaccinationCertificate.hcert.dgc
        guard let dgc = digitalGreenCert else {
            return nil
        }
        return String(format: Constants.Keys.validation_check_popup_test_date_of_birth, DateUtils.displayDateOfBirth(dgc))
    }
    var seconResultViewIsHidden: Bool {
        initialTokenIsBoosted && !(firstResult?.error != nil)
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
    var someIsFailed: Bool { secondResult?.error != nil || firstResult?.error != nil  }
    var areBothScanned: Bool { firstResult != nil && secondResult != nil}
    var firstResult: GProofValidationResult? = nil
    var secondResult: GProofValidationResult? = nil
    var firstIsFailedTechnicalReason: Bool { (firstResult?.error != nil) }
    var secondIsFailedTechnicalReason: Bool { (secondResult?.error != nil) }
    let router: GProofRouterProtocol
    let countdownTimerModel: CountdownTimerModel
    weak var delegate: ViewModelDelegate?
    private var initialTokenIsBoosted: Bool = false
    private var error: Error?
    private let repository: VaccinationRepositoryProtocol
    private let revocationRepository: CertificateRevocationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private var userDefaults: Persistence
    private var boosterAsTest: Bool
    private var resolvable: Resolver<ExtendedCBORWebToken>
    private var isFirstScan = true
    private var firstToken: ExtendedCBORWebToken? { firstResult?.token }
    private var secondToken: ExtendedCBORWebToken? { secondResult?.token }

    init(resolvable: Resolver<ExtendedCBORWebToken>,
         router: GProofRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         revocationRepository: CertificateRevocationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol,
         userDefaults: Persistence,
         boosterAsTest: Bool,
         countdownTimerModel: CountdownTimerModel
    ) {
        self.countdownTimerModel = countdownTimerModel
        self.resolvable = resolvable
        self.repository = repository
        self.revocationRepository = revocationRepository
        self.certLogic = certLogic
        self.userDefaults = userDefaults
        self.router = router
        self.boosterAsTest = boosterAsTest
        self.countdownTimerModel.onUpdate = onCountdownTimerModelUpdate
    }

    private func onCountdownTimerModelUpdate(countdownTimerModel: CountdownTimerModel) {
        if countdownTimerModel.shouldDismiss {
            cancel()
        } else {
            delegate?.viewModelDidUpdate()
        }
    }

    func scanQRCode() {
        isLoading = true
        var tmpToken: ExtendedCBORWebToken?
        firstly {
            router.scanQRCode()
        }
        .then { $0.mapOnScanResult() }
        .then {
            ParseCertificateUseCase(scanResult: $0,
                                    vaccinationRepository: self.repository).execute()
        }
        .then { token -> Promise<ValidateCertificateUseCase.Result> in
            tmpToken = token
            return ValidateCertificateUseCase(token: token,
                                              revocationRepository: self.revocationRepository,
                                              certLogic: self.certLogic,
                                              persistence: self.userDefaults,
                                              allowExceptions: true).execute()
        }
        .cancelled {
            if self.isFirstScan {
                self.router.sceneCoordinator.dimiss(animated: true)
            }
        }
        .done {
            self.validationToken(token: $0.token, error: nil, result: $0.validationResults)
        }
        .ensure {
            self.isLoading = false
        }
        .catch {
            self.validationToken(token: tmpToken, error: $0, result: nil)
        }
    }

    private func validationToken(token: ExtendedCBORWebToken?, error: Error?, result: [ValidationResult]?) {
        firstly {
            try self.preventSettingSameQRCode(token)
        }
        .then {
            self.setResultViewModel(error: error, newToken: $0, result: result)
        }
        .then {
            self.checkIfSamePerson()
        }
        .ensure {
            self.startAutomaticDismissal()
        }
        .done {
            self.delegate?.viewModelDidUpdate()
        }
        .catch {
            self.errorHandling($0, token: token, result: result)
        }
    }
    
    private func errorHandling(_ error: Error, token: ExtendedCBORWebToken?, result: [ValidationResult]?) {
        self.error = error
        if (error as? QRCodeError) == .qrCodeExists {
            router.showError(error: error)
        } else if isFirstScan && (error is ScanError || error is Base45CodingError || error is CertificateError) {
            showErorResultPage(error: error, token: token)
            setResultViewModel(error: error, newToken: token, result: result).cauterize()
        } else {
            setResultViewModel(error: error, newToken: token, result: result).cauterize()
        }
    }
    
    private func showErorResultPage(error: Error, token: ExtendedCBORWebToken?) {
        let showStartOverButton = !isFirstScan
        router.showCertificate(token,
                               _2GContext: true,
                               error: error,
                               userDefaults: userDefaults,
                               buttonHidden: showStartOverButton)
            .done { token in
                self.validationToken(token: token, error: error, result: nil)
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

    private func startAutomaticDismissal() {
        countdownTimerModel.start()
    }

    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case let .success(payload):
            return payload
        case let .failure(error):
            throw error
        }
    }
    
    private func preventSettingSameQRCode(_ newToken: ExtendedCBORWebToken?) throws -> Promise<ExtendedCBORWebToken> {
        guard let newToken = newToken else {
            return .init(error: CertificateError.invalidEntity)
        }

        let certTypeIsNotAlreadyScanned = firstToken?.vaccinationCertificate.certType != newToken.vaccinationCertificate.certType
        let exceptionBoosterWillReplaceCurrent = (newToken.vaccinationCertificate.hcert.dgc.isVaccinationBoosted && boosterAsTest)
        guard certTypeIsNotAlreadyScanned || exceptionBoosterWillReplaceCurrent else {
            throw QRCodeError.qrCodeExists
        }
        return .value(newToken)
    }
    
    private func convertOpenResultOfFirstCertificateToPassed() {
        if var openResults = firstResult?.result?.openResults {
            openResults.resultOfRuleRRDE0002 = .passed
        }
    }
    
    private func convertOpenResultOfSecondCertificate(to result: CertLogic.Result) {
        if var openResults = secondResult?.result?.openResults {
            openResults.resultOfRuleRRDE0002 = .passed
        }
    }
    
    private func setResultViewModel(error: Error?, newToken: ExtendedCBORWebToken?, result: [ValidationResult]?) -> Promise<Void> {
        initialTokenIsBoosted = newToken?.vaccinationCertificate.hcert.dgc.isVaccinationBoosted ?? false && boosterAsTest

        if isFirstScan || initialTokenIsBoosted {
            firstResult = .init(token: newToken, error: error, result: result)
        } else {
            secondResult = .init(token: newToken, error: error, result: result)
        }
                
        let doesFirstScanContaintOpenResults: Bool = !(firstResult?.result?.openResults.isEmpty ?? true)
        let doesSecondScanContaintOpenResults: Bool = !(secondResult?.result?.openResults.isEmpty ?? true)

        if doesFirstScanContaintOpenResults, secondToken?.firstVaccination?.fullImmunizationValidCheckApp ?? false {
            convertOpenResultOfFirstCertificateToPassed()
        } else if doesFirstScanContaintOpenResults,
                    secondToken?.vaccinationCertificate.isVaccination == false,
                    error as? ValidationResultError != .functional {
            secondResult = nil
            router.showRecovery90DaysError(error: QRCodeError.qrCodeExists)
        } else if doesSecondScanContaintOpenResults, firstToken?.firstVaccination?.fullImmunizationValidCheckApp ?? false {
            convertOpenResultOfSecondCertificate(to: .passed)
        } else if doesSecondScanContaintOpenResults, firstToken?.vaccinationCertificate.isVaccination == false {
            convertOpenResultOfSecondCertificate(to: .fail)
            secondResult = .init(token: newToken, error: ValidationResultError.functional, result: result)
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
        guard let firstResultCert = firstToken, !(firstResult?.error != nil) else {
            return .value
        }
        guard let secondResultCert = secondToken, !(secondResult?.error != nil) else {
            return .value
        }

        countdownTimerModel.reset()
        return router.showDifferentPerson(
            firstResultCert: firstResultCert.vaccinationCertificate,
            scondResultCert: secondResultCert.vaccinationCertificate
        )
        .get { result in
            switch result {
            case .startover:
                self.startover()
            case .retry:
                self.retry()
            case .cancel:
                self.cancel()
            }
        }
        .asVoid()
    }
    
    private var certificateAndTestNameOrDateOfBirthAreNotMatching: Bool {
        firstToken?.vaccinationCertificate.hcert.dgc !=
        secondToken?.vaccinationCertificate.hcert.dgc
    }
    
    func scanNext() {
        isFirstScan = false
        countdownTimerModel.reset()
        scanQRCode()
    }
    
    func retry() {
        isFirstScan = false
        secondResult = nil
        countdownTimerModel.reset()
        delegate?.viewModelDidUpdate()
        scanQRCode()
    }
    
    func startover() {
        isFirstScan = true
        secondResult = nil
        firstResult = nil
        countdownTimerModel.reset()
        delegate?.viewModelDidUpdate()
        scanQRCode()
    }
    
    func cancel() {
        router.sceneCoordinator.dimiss(animated: true)
    }
    
    func showFirstCardResult() {
        router
            .showCertificate(firstToken,
                             _2GContext: true,
                             error: firstResult?.error,
                             userDefaults: userDefaults,
                             buttonHidden: true)
            .cauterize()
    }
    
    func showSecondCardResult() {
        router
            .showCertificate(secondToken,
                             _2GContext: true,
                             error: secondResult?.error,
                             userDefaults: userDefaults,
                             buttonHidden: true)
            .cauterize()
    }
}

private extension Array where Element == ValidationResult {
    
    var resultOfRuleRRDE0002: CertLogic.Result? {
        get {
            validationResult(ofRule: "RR-DE-0002")?.result
        }
        set {
            guard let newValue = newValue else {
                return
            }
            validationResult(ofRule: "RR-DE-0002")?.result = newValue
        }
    }
}
