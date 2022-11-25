//
//  CertificateHolderImmunizationStatusViewModelMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import UIKit

struct CertificateHolderImmunizationStatusViewModelMock: CertificateHolderImmunizationStatusViewModelProtocol {
    var icon = UIImage()
    var title = "TITLE"
    var subtitle: String?
    var description = "DESCRIPTION"
    var date: String?
    var federalState: String?
    var federalStateText: String?
    let linkLabel: String? = nil
    let notice: String? = nil
    let noticeText: String? = nil
    let selectFederalStateButtonTitle: String? = nil
}
