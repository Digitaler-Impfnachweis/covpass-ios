//
//  ValidationResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    static let confirmButtonLabel = "validation_check_popup_valid_vaccination_button_title".localized
    static let confirmButtonLabel2G = "result_2G_button_startover".localized
}

extension ValidationViewModel {
    
    var linkIsHidden: Bool {
        !userDefaults.revocationExpertMode || _2GContext
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

    func scanNextCertifcate() {
        firstly {
            router.scanQRCode()
        }
        .map {
            try self.payloadFromScannerResult($0)
        }
        .then {
            self.repository.validCertificate($0)
        }
        .done { certificate in
            if self._2GContext {
                resolvable.fulfill(certificate)
                return
            }
            
            let vm = ValidationResultFactory.createViewModel(
                resolvable: resolvable,
                router: self.router,
                repository: self.repository,
                certificate: certificate,
                error: nil,
                type: UserDefaultsPersistence().selectedLogicType,
                certLogic: DCCCertLogic.create(),
                _2GContext: _2GContext,
                userDefaults: userDefaults
            )
            self.delegate?.viewModelDidChange(vm)
        }
        .catch { error in
            let vm = ValidationResultFactory.createViewModel(
                resolvable: resolvable,
                router: self.router,
                repository: self.repository,
                certificate: nil,
                error: error,
                type: UserDefaultsPersistence().selectedLogicType,
                certLogic: DCCCertLogic.create(),
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
