//
//  DialogRouterProtocol+ScanError.swift
//  CovPassApp
//
//  Created by Sebastian Maschinski on 23.05.21.
//  Copyright © 2021 IBM. All rights reserved.
//

import CovPassCommon
import CovPassUI

extension DialogRouterProtocol {
    func showDialogForScanError(_ error: Error, completion: (()-> Void)? = nil) {
        switch error {
        case QRCodeError.versionNotSupported:
            showDialog(
                title: "error_scan_present_data_is_not_supported_title".localized,
                message: "error_scan_present_data_is_not_supported_message".localized,
                actions: [
                    DialogAction(
                        title: "error_scan_present_data_is_not_supported_button_title".localized,
                        style: .cancel,
                        completion: { _ in completion?() }
                    )
                ],
                style: .alert
            )
        case HCertError.verifyError:
            showDialog(
                title: "error_scan_qrcode_without_seal_title".localized,
                message: "error_scan_qrcode_without_seal_message".localized,
                actions: [
                    DialogAction(
                        title: "error_scan_qrcode_without_seal_button_title".localized,
                        style: .cancel,
                        completion: { _ in completion?() }
                    )
                ],
                style: .alert
            )
        case QRCodeError.qrCodeExists:
            showDialog(
                title: "duplicate_certificate_dialog_header".localized,
                message: "duplicate_certificate_dialog_message".localized,
                actions: [
                    DialogAction(
                        title: "duplicate_certificate_dialog_button_title".localized,
                        style: .cancel,
                        completion: { _ in completion?() }
                    )
                ],
                style: .alert
            )
        default:
            showDialog(
                title: "error_scan_qrcode_cannot_be_parsed_title".localized,
                message: "error_scan_qrcode_cannot_be_parsed_message".localized,
                actions: [
                    DialogAction(
                        title: "error_scan_qrcode_cannot_be_parsed_button_title".localized,
                        style: .cancel,
                        completion: { _ in completion?() }
                    )
                ],
                style: .alert
            )
        }
    }
}
