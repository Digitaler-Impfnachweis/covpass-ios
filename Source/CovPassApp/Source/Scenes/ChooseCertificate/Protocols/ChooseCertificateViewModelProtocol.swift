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
    var title: String { get }
    var subtitle: String { get }
    var certdetails: String { get }
    var certificatesAvailable: Bool { get }
    func refreshCertificates() -> Promise<Void>
    func cancel()
}
