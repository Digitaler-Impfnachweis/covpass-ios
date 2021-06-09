//
//  DialogRouterProtocol+DidDeleteCertificate.swift
//  CovPassApp
//
//  Created by Sebastian Maschinski on 23.05.21.
//  Copyright © 2021 IBM. All rights reserved.
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
