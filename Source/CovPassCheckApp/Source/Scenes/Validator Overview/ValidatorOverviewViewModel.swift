//
//  ValidatorViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit
import UIKit

class ValidatorOverviewViewModel {
    // MARK: - Properties

    private let repository: VaccinationRepositoryProtocol
    private let router: ValidatorOverviewRouterProtocol

    var delegate: ViewModelDelegate?

    var title: String { "validation_start_screen_title".localized }

    var offlineAvailable: Bool {
        guard let lastUpdated = repository.getLastUpdatedTrustList(),
              let date = Calendar.current.date(byAdding: .day, value: 1, to: lastUpdated),
              Date() < date
        else {
            return false
        }
        return true
    }

    var offlineIcon: UIImage {
        offlineAvailable ? .validationCheckmark : .warning
    }

    var offlineTitle: String {
        offlineAvailable ? "validation_start_screen_offline_modus_note_latest_version".localized : "validation_start_screen_offline_modus_note_old_version".localized
    }

    var offlineMessage: String {
        let date = repository.getLastUpdatedTrustList() ?? Date(timeIntervalSince1970: 0)
        return String(format: "%@ %@", "validation_start_screen_offline_modus_note_update".localized, DateUtils.displayDateFormatter.string(from: date))
    }

    // MARK: - Lifecycle

    init(router: ValidatorOverviewRouterProtocol, repository: VaccinationRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }

    // MARK: - Methods

    func updateTrustList() {
        repository
            .updateTrustList()
            .done {
                self.delegate?.viewModelDidUpdate()
            }
            .catch { _ in }
    }

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
