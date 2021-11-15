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
import CovPassCommon

protocol ChooseCertificateViewModelProtocol {
    var router: ChooseCertificateRouterProtocol? { get set }
    var delegate: ViewModelDelegate? { get set }
    var items: [CertificateItem] { get }
    var typeFilter: [CertType]  { get set }
    var givenNameFilter: String { get set }
    var familyNameFilter: String  { get set }
    var dobFilter: String  { get set}
    var title: String { get }
    var subtitle: String { get }
    var certdetails: String { get }
    var noMatchTitle: String { get }
    var noMatchSubtitle: String { get }
    var noMatchImage: UIImage { get }
    var certificatesAvailable: Bool { get }
    var isLoading: Bool { get }
    func refreshCertificates()
    func cancel()
}
