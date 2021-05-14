//
//  ValidatorViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import UIKit
import VaccinationCommon
import VaccinationUI

class ValidatorViewModel {
    // MARK: - Private

    private let repository: VaccinationRepositoryProtocol
    private let router: ValidatorRouterProtocol
    private let parser = QRCoder()

    // MARK: - Internal

    var title: String { "validation_start_screen_title".localized }

    var offlineTitle: String {
        "validation_start_screen_offline_modus_note_latest_version".localized
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
        repository.checkVaccinationCertificate(payload)
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
        .catch { _ in
            self.router.showCertificate(nil)
        }
    }

    func showAppInformation() {
        router.showAppInformation()
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
