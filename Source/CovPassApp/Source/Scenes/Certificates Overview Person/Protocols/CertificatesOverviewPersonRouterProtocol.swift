//
//  CertificatesOverviewPersonRouterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import CovPassCommon

protocol CertificatesOverviewPersonRouterProtocol: DialogRouterProtocol {
    func showCertificatesDetail(certificates: [ExtendedCBORWebToken]) -> Promise<CertificateDetailSceneResult>
}
