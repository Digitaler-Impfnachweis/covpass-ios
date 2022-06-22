//
//  CertificateImportSelectionViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI

protocol CertificateImportSelectionViewModelProtocol {
    var title: String { get }
    var buttonTitle: String { get }
    var selectionTitle: String { get }
    var hintTitle: String { get }
    var hintTextBulletPoints: [String] { get }
    var items: [CertificateImportSelectionItem] { get }
    var itemSelectionState: CertificateImportSelectionState { get }
    var enableButton: Bool { get }
    var hideSelection: Bool { get }

    func confirm()
    func cancel()
    func toggleSelection()
}

enum CertificateImportSelectionState {
    case none
    case all
    case some
}
