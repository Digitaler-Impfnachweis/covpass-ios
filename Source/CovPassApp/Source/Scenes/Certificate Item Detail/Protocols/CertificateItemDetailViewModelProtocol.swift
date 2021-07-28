//
//  CertificateItemDetailViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

protocol CertificateItemDetailViewModelProtocol {
    var title: String { get }
    var showSubtitle: Bool { get }
    var headline: String { get }
    var items: [(String, String)] { get }
    func showQRCode()
    func startPDFExport()
    func deleteCertificate()
}
