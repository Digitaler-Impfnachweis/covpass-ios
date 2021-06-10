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

    weak var delegate: ResultViewModelDelegate?
    let router: ValidationResultRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificate: CBORWebToken?

    var icon: UIImage? {
        guard let rCert = certificate?.hcert.dgc.r?.first, rCert.isValid else {
            return .resultError
        }
        return .resultSuccess
    }

    var resultTitle: String {
        guard let rCert = certificate?.hcert.dgc.r?.first, rCert.isValid else {
            return "validation_check_popup_unsuccessful_certificate_title".localized
        }
        return "validation_check_popup_valid_vaccination_recovery_title".localized
    }

    var resultBody: String {
        guard let rCert = certificate?.hcert.dgc.r?.first, rCert.isValid else {
            return "validation_check_popup_unsuccessful_certificate_message".localized
        }
        return "validation_check_popup_valid_vaccination_recovery_message".localized
    }

    var paragraphs: [Paragraph] {
        guard let dob = certificate?.hcert.dgc.dob, let rCert = certificate?.hcert.dgc.r?.first, rCert.isValid else {
            return [
                Paragraph(icon: .timeHui, title: "validation_check_popup_unsuccessful_certificate__recovery_title".localized, subtitle: "validation_check_popup_unsuccessful_certificate_recovery_body".localized),
                Paragraph(icon: .statusPartialDetail, title: "validation_check_popup_unsuccessful_certificate__vaccination_title".localized, subtitle: "validation_check_popup_unsuccessful_certificate_vaccination_body".localized),
                Paragraph(icon: .iconTest, title: "validation_check_popup_unsuccessful_certificate__test_title".localized, subtitle: "validation_check_popup_unsuccessful_certificate_test_body".localized),
                Paragraph(icon: .technicalError, title: "validation_check_popup_unsuccessful_certificate__problem_title".localized, subtitle: "validation_check_popup_unsuccessful_certificate_problem_body".localized)
            ]
        }
        return [
            Paragraph(icon: .data, title: certificate?.hcert.dgc.nam.fullName ?? "", subtitle: String(format: "validation_check_popup_valid_pcr_test_less_than_72_h_date_of_birth".localized, DateUtils.displayDateFormatter.string(from: dob)))
        ]
    }

    var info: String? {
        guard let rCert = certificate?.hcert.dgc.r?.first, rCert.isValid else {
            return nil
        }
        return "validation_check_popup_valid_vaccination_recovery_note".localized
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
