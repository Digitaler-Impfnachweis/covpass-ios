//
//  ImprintViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

private enum Constants {
    static let title = "app_imprint_title".localized(bundle: .main)
    static let subtitle = "app_imprint_subtitle".localized(bundle: .main)
    static let publisher = "app_imprint_publisher".localized(bundle: .main)
    static let address = "app_imprint_address".localized(bundle: .main)
    static let contactTitle = "app_imprint_contact_title".localized(bundle: .main)
    static let contactMail = "app_imprint_contact_mail".localized(bundle: .main)
    static let contactForm = "app_imprint_contact_form".localized(bundle: .main)
    static let vatNumberTitle = "app_imprint_identnr_title".localized(bundle: .main)
    static let vatNumber = "app_imprint_identnr_nr".localized(bundle: .main)
}

final class ImprintViewModel: ImprintViewModelProtocol {
    // MARK: - Properties

    let title = Constants.title
    let subtitle = Constants.subtitle
    let publisher = Constants.publisher
    let address = Constants.address
    let contactTitle = Constants.contactTitle
    let contactMail = Constants.contactMail
    let contactForm = Constants.contactForm
    let vatNumberTitle = Constants.vatNumberTitle
    let vatNumber = Constants.vatNumber

    // MARK: - Lifecycle

    init() {}
}
