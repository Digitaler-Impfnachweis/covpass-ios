//
//  TestResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class TestResultViewModel: ValidationResultViewModel {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: ValidationResultRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificate: CBORWebToken?

    private var isPCR: Bool {
        certificate?.hcert.dgc.t?.first?.isPCR ?? false
    }

    var icon: UIImage? {
        .group
    }

    var resultTitle: String {
        guard let testCert = certificate?.hcert.dgc.t?.first else {
            return "" // TODO error
        }
        if isPCR {
            if testCert.isPositive {
                return String(format: "validation_check_popup_pcr_test_positive_title".localized, DateUtils.displayDateFormatter.string(from: testCert.sc))
            }
            if testCert.isValid {
                let diffComponents = Calendar.current.dateComponents([.hour], from: testCert.sc, to: Date())
                return String(format: "validation_check_popup_valid_pcr_test_less_than_72_h_title".localized, diffComponents.hour ?? 0)
            }
            return String(format: "validation_check_popup_valid_pcr_test_older_than_72_h_title".localized, DateUtils.displayDateFormatter.string(from: testCert.sc))
        }
        if testCert.isPositive {
            return ""
        }
        if testCert.isValid {
            let diffComponents = Calendar.current.dateComponents([.hour], from: testCert.sc, to: Date())
            return String(format: "validation_check_popup_test_less_than_24_h_title".localized, diffComponents.hour ?? 0)
        }
        return String(format: "validation_check_popup_test_older_than_24_h_title".localized, DateUtils.displayDateFormatter.string(from: testCert.sc))
    }

    var resultBody: String {
        guard let testCert = certificate?.hcert.dgc.t?.first else {
            return "" // TODO error
        }
        if testCert.isPositive && !testCert.isPCR {
            return "validation_check_popup_test_positive_message".localized
        }
        return "validation_check_popup_test_older_than_24_h_message".localized
    }

    var nameTitle: String? {
        guard let testCert = certificate?.hcert.dgc.t?.first else {
            return "" // TODO error
        }
        if testCert.isPositive && !testCert.isPCR {
            return nil
        }
        return certificate?.hcert.dgc.nam.fullName
    }

    var nameBody: String? {
        guard let testCert = certificate?.hcert.dgc.t?.first else {
            return "" // TODO error
        }
        if testCert.isPositive && !testCert.isPCR {
            return nil
        }
        if let date = certificate?.hcert.dgc.dob {
            return String(format: "validation_check_popup_test_older_than_24_h_date_of_birth".localized, DateUtils.displayDateFormatter.string(from: date))
        }
        return nil
    }

    var errorTitle: String? {
        guard let testCert = certificate?.hcert.dgc.t?.first else {
            return "" // TODO error
        }
        if testCert.isPositive && !testCert.isPCR {
            return nil
        }
        return String(format: "validation_check_popup_pcr_test_positive_date_of_issue".localized, DateUtils.displayDateFormatter.string(from: testCert.sc), DateUtils.displayTimeFormatter.string(from: testCert.sc))
    }

    var errorBody: String? {
        guard let testCert = certificate?.hcert.dgc.t?.first else {
            return "" // TODO error
        }
        if testCert.isPositive && !testCert.isPCR {
            return nil
        }
        return DateUtils.displayTimeZoneFormatter.string(from: testCert.sc)
    }

    var nameIcon: UIImage? {
        guard let testCert = certificate?.hcert.dgc.t?.first else {
            return .validationSearch
        }
        if testCert.isPositive && !testCert.isPCR {
            return nil
        }
        return .data
    }

    var errorIcon: UIImage? {
        .validationPending
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
