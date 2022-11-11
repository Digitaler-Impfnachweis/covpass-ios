//
//  CertificateInvalidResultRouterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

protocol CertificateInvalidResultRouterProtocol {
    func revoke(token: ExtendedCBORWebToken, revocationKeyFilename: String)
}
