//
//  CertificatesOverviewViewModelDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

protocol CertificatesOverviewViewModelDelegate: AnyObject {
    func viewModelDidUpdate()
    func viewModelDidUpdateFavorite()
    func viewModelDidDeleteCertificate()
    func viewModelUpdateDidFailWithError(_ error: Error)
}
