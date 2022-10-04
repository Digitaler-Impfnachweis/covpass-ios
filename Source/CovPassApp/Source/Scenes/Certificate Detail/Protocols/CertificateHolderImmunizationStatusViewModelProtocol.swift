//
//  CertificateHolderImmunizationStatusViewModelProtocol.swift.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

protocol CertificateHolderImmunizationStatusViewModelProtocol {
    var icon: UIImage { get }
    var title: String { get }
    var subtitle: String? { get }
    var description: String { get }
}