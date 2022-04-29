//
//  ValidationViewModel+Extension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit
import CertLogic

private enum Constants {
    static let confirmButtonLabel = "validation_check_popup_valid_vaccination_button_title".localized
    static let confirmButtonLabel2G = "result_2G_button_startover".localized
    static let revocationBody = "validation_check_popup_revoked_certificate_box_text".localized
    static let revocationTitle = "revocation_headline".localized
}

extension ValidationViewModelProtocol {
    
    var revocationInfoHidden: Bool {
        !userDefaults.revocationExpertMode || _2GContext
    }

    var revocationInfoText: String {
        Constants.revocationBody
    }

    var revocationHeadline: String {
        Constants.revocationTitle
    }
        
    var toolbarState: CustomToolbarState {
        let buttonText = _2GContext ? Constants.confirmButtonLabel2G : Constants.confirmButtonLabel
        return .confirm(buttonText)
    }
    
    func revocationButtonTapped() {
        guard let certificate = self.certificate else { return }
        router
            .showRevocation(token: certificate, keyFilename: revocationKeyFilename)
            .cauterize()
    }
    
    func cancel() {
        router.showStart()
        resolvable.cancel()
    }
    
    func scanCertificate() {
        var tmpToken: ExtendedCBORWebToken?
        scanCertificateStarted()
        firstly {
            router.scanQRCode()
        }
        .then {
            ParseCertificateUseCase(scanResult: $0,
                                    vaccinationRepository: repository).execute()
        }
        .then { token -> Promise<ValidateCertificateUseCase.Result> in
            tmpToken = token
            return ValidateCertificateUseCase(token: token,
                                              revocationRepository: CertificateRevocationRepository()!,
                                              certLogic: DCCCertLogic.create(),
                                              persistence: self.userDefaults).execute()
        }
        .done { result in
            if self._2GContext {
                resolvable.fulfill(result.token)
                return
            }
            
            let vm = ValidationResultFactory.createViewModel(
                resolvable: resolvable,
                router: self.router,
                repository: self.repository,
                certificate: result.token,
                error: nil,
                _2GContext: _2GContext,
                userDefaults: userDefaults
            )
            self.delegate?.viewModelDidChange(vm)
        }
        .ensure {
            scanCertificateEnded()
        }
        .catch { error in
            let vm = ValidationResultFactory.createViewModel(
                resolvable: resolvable,
                router: self.router,
                repository: self.repository,
                certificate: tmpToken,
                error: error,
                _2GContext: _2GContext,
                userDefaults: userDefaults
            )
            self.delegate?.viewModelDidChange(vm)
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
}
