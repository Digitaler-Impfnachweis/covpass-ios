//
//  CertificateDetailRouterProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

protocol CertificateDetailRouterProtocol: DialogRouterProtocol {
    func showDetail(for certificate: ExtendedCBORWebToken) -> Promise<CertificateDetailSceneResult>
    func showWebview(_ url: URL)
    @discardableResult
    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void>
}
