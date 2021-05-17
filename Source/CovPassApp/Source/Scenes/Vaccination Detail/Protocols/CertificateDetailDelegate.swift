//
//  CertificateDetailDelegate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

protocol CertificateDetailDelegate: AnyObject {
    func didAddCertificate()
    func didAddFavoriteCertificate()
    func didDeleteCertificate()
    func select(certificates: [ExtendedCBORWebToken])
}
