//
//  ChooseCertificateViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit
import PromiseKit

protocol ChooseCertificateViewModelProtocol {
    var router: ChooseCertificateRouterProtocol { get set }
    var delegate: ViewModelDelegate? { get set }
    var items: [CertificateItem] { get }
    var name: String { get }
    func refreshCertificates() -> Promise<Void>
}
