//
//  ReissueSuccessViewViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit

private enum Constants {
    static let title = "certificate_renewal_confirmation_page_headline".localized
    static let subTitle = "renewal_expiry_success_copy".localized
    static let submitButton = "renewal_expiry_success_button".localized
    static let shareButtonTitle = "renewal_expiry_success_download_button".localized
}

final class ReissueSuccessViewViewModel: ResultViewViewModel {
    init(resolver: Resolver<Void>,
         router: ResultViewRouterProtocol,
         certificate: ExtendedCBORWebToken) {
        super.init(
            image: .successLarge,
            title: Constants.title,
            description: Constants.subTitle,
            buttonTitle: Constants.submitButton,
            shareButtonTitle: Constants.shareButtonTitle,
            resolver: resolver,
            router: router,
            certificate: certificate
        )
    }
}
