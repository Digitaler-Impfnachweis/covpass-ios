//
//  CertificateImportSuccessViewViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit

private enum Constants {
    static let title = "file_import_success_title".localized
    static let description = "file_import_success_copy".localized
    static let buttonTitle = "file_import_success_button".localized
}

final class CertificateImportSuccessViewViewModel: ResultViewViewModel {
    init(resolver: Resolver<Void>) {
        super.init(
            image: .successLarge,
            title: Constants.title,
            description: Constants.description,
            buttonTitle: Constants.buttonTitle,
            resolver: resolver
        )
    }
}
