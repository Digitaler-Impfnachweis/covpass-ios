//
//  DialogRouterProtocol+DidDeleteCertificate.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit

extension DialogRouterProtocol {
    func showCertificateDidDeleteDialog() {
        showDialog(
            title: "delete_result_dialog_header".localized,
            message: "delete_result_dialog_message".localized,
            actions: [
                DialogAction(
                    title: "delete_result_dialog_positive_button_text".localized,
                    style: .default
                )
            ],
            style: .alert
        )
    }
}
