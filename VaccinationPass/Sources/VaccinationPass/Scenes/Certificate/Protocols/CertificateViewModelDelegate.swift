//
//  CertificateViewModelDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

protocol CertificateViewModelDelegate: AnyObject {
    func viewModelDidUpdate()
    func viewModelDidUpdateFavorite()
    func viewModelDidAddCertificate()
    func viewModelDidDeleteCertificate()
    func viewModelUpdateDidFailWithError(_ error: Error)
}
