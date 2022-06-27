//
//  CertificateImportSelectionRouterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit

protocol CertificateImportSelectionRouterProtocol {
    func showTooManyHoldersError()
    func showImportSuccess() -> Promise<Void>
}
