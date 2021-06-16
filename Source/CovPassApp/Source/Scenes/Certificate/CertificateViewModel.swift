//
//  CertificateViewModel.swift
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

class CertificateViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let token: ExtendedCBORWebToken
    let resolver: Resolver<Void>

    var image: UIImage? {
        token.vaccinationQRCodeData.generateQRCode(size: UIScreen.main.bounds.size)
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
