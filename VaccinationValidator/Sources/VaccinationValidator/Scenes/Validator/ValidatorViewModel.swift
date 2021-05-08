//
//  ValidatorViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationUI
import UIKit
import VaccinationCommon
import PromiseKit

class ValidatorViewModel {
    // MARK: - Private

    private let repository: VaccinationRepositoryProtocol
    private let router: ValidatorRouterProtocol
    private let parser: QRCoder = QRCoder()
    
    // MARK: - Internal
    
    var title: String { "validation_start_screen_title".localized }

    // TODO implmement logic
    var offlineTitle: String {
        if true {
            return "validation_start_screen_offline_modus_note_latest_version".localized
        } else {
            return "validation_start_screen_offline_modus_note_old_version".localized
        }
    }

    var offlineMessage: String {
        let date = "01.01.1970"
        return String(format: "%@ %@", "validation_start_screen_offline_modus_note_update".localized, date)
    }
    
    // MARK: - UIConfigureation
    
    let continerCornerRadius: CGFloat = 20
    let continerHeight: CGFloat = 200
    var headerButtonInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0)

    // MARK: - Lifecycle

    init(router: ValidatorRouterProtocol, repository: VaccinationRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }

    // MARK: - Actions

    func process(payload: String) -> Promise<CBORWebToken> {
        repository.checkValidationCertificate(payload)
    }

    func startQRCodeValidation() {
        firstly {
            router.scanQRCode()
        }
        .map {
            try self.payloadFromScannerResult($0)
        }
        .then {
            self.process(payload: $0)
        }
        .done {
            self.router.showCertificate($0)
        }
        .cauterize()
    }

    func showAppInformation() {
        router.showAppInformation()
    }

    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case .success(let payload):
            return payload
        case .failure(let error):
            throw error
        }
    }
}
