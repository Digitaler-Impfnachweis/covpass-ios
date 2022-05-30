//
//  CertificatesOverviewPersonViewModelDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

protocol CertificatesOverviewPersonViewModelDelegate: AnyObject {
    func viewModelDidUpdate()
    func viewModelNeedsFirstCertificateVisible()
    func viewModelNeedsCertificateVisible(at index: Int)
}
