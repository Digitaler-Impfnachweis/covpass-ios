//
//  CertificateViewModel.swift
//  CovPassApp
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import UIKit
import CovPassUI
import CovPassCommon

class CertificateViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let token: ExtendedCBORWebToken
    let resolver: Resolver<Void>

    var image: UIImage? {
        token.vaccinationQRCodeData.generateQRCode(size: UIScreen.main.bounds.size)
    }

    var title: String {
        let number = token.vaccinationCertificate.hcert.dgc.v.first?.dn ?? 0
        let total = token.vaccinationCertificate.hcert.dgc.v.first?.sd ?? 0
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
