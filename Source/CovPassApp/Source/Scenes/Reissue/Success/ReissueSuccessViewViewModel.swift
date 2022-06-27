//
//  ReissueSuccessViewViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit

private enum Constants {
        static var title = "certificate_renewal_confirmation_page_headline".localized
        static var subTitle = "renewal_expiry_success_copy".localized
        static var submitButton = "renewal_expiry_success_button".localized
}

final class ReissueSuccessViewViewModel: ResultViewViewModel {
    init(resolver: Resolver<Void>) {
        super.init(
            image: .successLarge,
            title: Constants.title,
            description: Constants.subTitle,
            buttonTitle: Constants.submitButton,
            resolver: resolver
        )
    }
}
