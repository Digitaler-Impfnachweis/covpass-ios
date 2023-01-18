//
// CertificateDetailSceneResult.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

enum CertificateDetailSceneResult {
    case didReissuedCertificate
    case didDeleteCertificate
    case showCertificatesOnOverview(ExtendedCBORWebToken)
    case addNewCertificate
}
