//
//  StartOnboardingViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import VaccinationCommon
import VaccinationUI

class ValidationResultViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: ValidationResultRouterProtocol
    private let parser = QRCoder()
    private var certificate: CBORWebToken?

    private var immunizationState: ImmunizationState {
        guard let cert = certificate else {
            return .error
        }
        return immunizationState(for: cert.hcert.dgc)
    }

    var icon: UIImage? {
        switch immunizationState {
        case .full:
            return .resultSuccess
        case .partial, .error:
            return .resultError
        }
    }

    var resultTitle: String {
        switch immunizationState {
        case .full:
            return "validation_check_popup_valid_vaccination_title".localized
        case .partial:
            return "validation_check_popup_vaccination_not_completely_title".localized
        case .error:
            return "validation_check_popup_unsuccessful_test_title".localized
        }
    }

    var resultBody: String {
        switch immunizationState {
        case .full:
            return "validation_check_popup_valid_vaccination_message".localized
        case .partial:
            return "validation_check_popup_vaccination_not_completely_message".localized
        case .error:
            return "validation_check_popup_unsuccessful_test_message".localized
        }
    }

    var nameTitle: String? {
        switch immunizationState {
        case .full, .partial:
            return certificate?.hcert.dgc.nam.fullName
        case .error:
            return "validation_check_popup_unsuccessful_test_first_reason_title".localized
        }
    }

    var nameBody: String? {
        switch immunizationState {
        case .full, .partial:
            if let date = certificate?.hcert.dgc.dob {
                return "\("validation_check_popup_partial_valid_vaccination_date_of_birth_at".localized) \(DateUtils.displayDateFormatter.string(from: date))"
            }
            return nil
        case .error:
            return "validation_check_popup_unsuccessful_test_first_reason_body".localized
        }
    }

    var errorTitle: String? {
        switch immunizationState {
        case .full, .partial:
            return ""
        case .error:
            return "validation_check_popup_unsuccessful_test_second_reason_title".localized
        }
    }

    var errorBody: String? {
        switch immunizationState {
        case .full, .partial:
            return ""
        case .error:
            return "validation_check_popup_unsuccessful_test_second_reason_body".localized
        }
    }

    // MARK: - Lifecycle

    init(
        router: ValidationResultRouterProtocol,
        certificate: CBORWebToken?
    ) {
        self.router = router
        self.certificate = certificate
    }

    var nameIcon: UIImage? {
        switch immunizationState {
        case .full, .partial:
            return .data
        case .error:
            return .validationSearch
        }
    }

    var errorIcon: UIImage? {
        .validationPending
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
            self.process(payload: $0)
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

    private func process(payload: String) -> Promise<CBORWebToken> {
        return parser.parse(payload)
    }

    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case let .success(payload):
            return payload
        case let .failure(error):
            throw error
        }
    }

    private func immunizationState(for certificate: DigitalGreenCertificate) -> ImmunizationState {
        return certificate.fullImmunizationValid ? .full : .partial
    }
}
