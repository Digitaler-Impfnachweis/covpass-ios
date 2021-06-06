//
//  RecoveryResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class RecoveryResultViewModel: ValidationResultViewModel {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: ValidationResultRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificate: CBORWebToken?

    private var validRecovery: Bool {
        guard let du = certificate?.hcert.dgc.r?.first?.du, Date() > du else {
            return false
        }
        return true
    }

    var icon: UIImage? {
        validRecovery ? .resultSuccess : .resultError
    }

    var resultTitle: String {
        validRecovery ? "validation_check_popup_recovery_proven_title".localized : "validation_check_popup_recovery_expired_title".localized
    }

    var resultBody: String {
        validRecovery ? "validation_check_popup_recovery_proven_message".localized : "validation_check_popup_recovery_expired_message".localized
    }

    var nameTitle: String? {
        validRecovery ? certificate?.hcert.dgc.nam.fullName : nil
    }

    var nameBody: String? {
        if validRecovery, let date = certificate?.hcert.dgc.dob {
            return "\("validation_check_popup_partial_valid_vaccination_date_of_birth_at".localized) \(DateUtils.displayDateFormatter.string(from: date))"
        }
        return nil
    }

    var errorTitle: String? {
        nil
    }

    var errorBody: String? {
        nil
    }

    var nameIcon: UIImage? {
        validRecovery ? .data : nil
    }

    var errorIcon: UIImage? {
        nil
    }

    // MARK: - Lifecycle

    init(
        router: ValidationResultRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificate: CBORWebToken?
    ) {
        self.router = router
        self.repository = repository
        self.certificate = certificate
    }

    // MARK: - Methods

    public func cancel() {
        router.showStart()
    }

    func scanNextCertifcate() {
        firstly {
            router.scanQRCode()
        }
        .map {
            try self.payloadFromScannerResult($0)
        }
        .then {
            self.repository.checkVaccinationCertificate($0)
        }
        .get {
            self.certificate = $0
        }
        .done { _ in
            self.delegate?.viewModelDidUpdate()
        }
        .catch { _ in
            self.certificate = nil
            self.delegate?.viewModelDidUpdate()
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
