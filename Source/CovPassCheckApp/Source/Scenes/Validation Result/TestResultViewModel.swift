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

    weak var delegate: ResultViewModelDelegate?
    let router: ValidationResultRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificate: CBORWebToken?

    var icon: UIImage? {
        guard let testCert = certificate?.hcert.dgc.t?.first, !testCert.isPositive, testCert.isValid, (testCert.isPCR || testCert.isAntigen) else {
            return .resultError
        }
        return .group
    }

    var resultTitle: String {
        // positive tests or error
        guard let testCert = certificate?.hcert.dgc.t?.first, !testCert.isPositive, testCert.isValid, (testCert.isPCR || testCert.isAntigen) else {
            return "validation_check_popup_unsuccessful_certificate_title".localized
        }
        // negative pcr
        if testCert.isPCR {
            let diffComponents = Calendar.current.dateComponents([.hour], from: testCert.sc, to: Date())
            return String(format: "validation_check_popup_valid_pcr_test_title".localized, diffComponents.hour ?? 0)
        }
        // negative rapid
        let diffComponents = Calendar.current.dateComponents([.hour], from: testCert.sc, to: Date())
        return String(format: "validation_check_popup_test_title".localized, diffComponents.hour ?? 0)
    }

    var resultBody: String {
        guard let testCert = certificate?.hcert.dgc.t?.first, !testCert.isPositive, testCert.isValid, (testCert.isPCR || testCert.isAntigen) else {
            return "validation_check_popup_unsuccessful_certificate_message".localized
        }
        return "validation_check_popup_valid_vaccination_recovery_message".localized
    }

    var paragraphs: [Paragraph] {
        guard let dob = certificate?.hcert.dgc.dob, let testCert = certificate?.hcert.dgc.t?.first, !testCert.isPositive, testCert.isValid, (testCert.isPCR || testCert.isAntigen) else {
            return [
                Paragraph(icon: .timeHui, title: "validation_check_popup_unsuccessful_certificate_not_valid_title".localized, subtitle: "validation_check_popup_unsuccessful_certificate_not_valid_message".localized),
                Paragraph(icon: .technicalError, title: "validation_check_popup_unsuccessful_certificate_technical_problems_title".localized, subtitle: "validation_check_popup_unsuccessful_certificate_technical_problems_message".localized)
            ]
        }
        return [
            Paragraph(icon: .data, title: certificate?.hcert.dgc.nam.fullName ?? "", subtitle: String(format: "validation_check_popup_test_date_of_birth".localized, DateUtils.displayDateFormatter.string(from: dob))),
            Paragraph(icon: .calendar, title: DateUtils.displayDateTimeFormatter.string(from: testCert.sc), subtitle: "validation_check_popup_test_date_of_issue".localized)
        ]
    }

    var info: String? {
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

    func cancel() {
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
            self.repository.checkCertificate($0)
        }
        .get {
            self.certificate = $0
        }
        .done { _ in
            let vm = ValidationResultFactory.createViewModel(
                router: self.router,
                repository: self.repository,
                certificate: self.certificate
            )
            self.delegate?.viewModelDidChange(vm)
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
