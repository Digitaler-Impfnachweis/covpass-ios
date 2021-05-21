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
import CovPassCommon
import CovPassUI

class ValidatorOverviewViewModel {
    // MARK: - Private

    private let repository: VaccinationRepositoryProtocol
    private let router: ValidatorOverviewRouterProtocol
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

    init(router: ValidatorOverviewRouterProtocol, repository: VaccinationRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }

    // MARK: - Actions

    func startQRCodeValidation() {
        firstly {
            router.scanQRCode()
        }
        .map {
            try self.payloadFromScannerResult($0)
        }
        .then {
            self.repository.checkVaccinationCertificate($0)
        }
        .done {
            self.router.showCertificate($0)
        }
        .catch { error in
            switch error {
            case QRCodeError.versionNotSupported:
                self.router.showDialog(title: "error_scan_present_data_is_not_supported_title".localized, message: "error_scan_present_data_is_not_supported_message".localized, actions: [DialogAction.cancel("error_scan_present_data_is_not_supported_button_title".localized)], style: .alert)
            case HCertError.verifyError:
                self.router.showDialog(title: "error_scan_qrcode_cannot_be_parsed_title".localized, message: "error_scan_qrcode_cannot_be_parsed_message".localized, actions: [DialogAction.cancel("error_scan_qrcode_cannot_be_parsed_button_title".localized)], style: .alert)
            default:
                self.router.showCertificate(nil)
            }
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
