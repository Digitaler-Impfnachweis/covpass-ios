//
//  CertificateViewModel.swift
//  CovPassApp
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit
import UIKit

class CertificateViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let token: ExtendedCBORWebToken
    let resolver: Resolver<Void>

    var image: UIImage? {
        token.vaccinationQRCodeData.generateQRCode(size: UIScreen.main.bounds.size)
    }

    var title: String {
        if token.vaccinationCertificate.hcert.dgc.r != nil {
            return "certificates_overview_recovery_certificate_message".localized
        }
        if let t = token.vaccinationCertificate.hcert.dgc.t?.first {
            return t.isPCR ? "certificates_overview_pcr_test_certificate_message".localized : "certificates_overview_test_certificate_message".localized
        }
        let number = token.vaccinationCertificate.hcert.dgc.v?.first?.dn ?? 0
        let total = token.vaccinationCertificate.hcert.dgc.v?.first?.sd ?? 0
        return String(format: "vaccination_certificate_detail_view_vaccination_title".localized, number, total)
    }

    // MARK: - Lifecycle

    init(
        token: ExtendedCBORWebToken,
        resolvable: Resolver<Void>
    ) {
        self.token = token
        resolver = resolvable
    }

    func done() {
        resolver.fulfill_()
    }

    func cancel() {
        resolver.cancel()
    }
}
