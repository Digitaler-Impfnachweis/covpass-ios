//
//  DialogRouterProtocol+ScanError.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI

extension DialogRouterProtocol {
    func showDialogForScanError(_ error: Error, completion: (() -> Void)? = nil) {
        switch error {
        case QRCodeError.versionNotSupported:
            showDialog(
                title: "error_scan_present_data_is_not_supported_title".localized,
                message: error.displayCodeWithMessage("error_scan_present_data_is_not_supported_message".localized),
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
                message: error.displayCodeWithMessage("error_scan_qrcode_without_seal_message".localized),
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
                message: error.displayCodeWithMessage("duplicate_certificate_dialog_message".localized),
                actions: [
                    DialogAction(
                        title: "duplicate_certificate_dialog_button_title".localized,
                        style: .cancel,
                        completion: { _ in completion?() }
                    )
                ],
                style: .alert
            )
        case CertificateError.positiveResult:
            showDialog(
                title: "error_test_certificate_not_valid_title".localized,
                message: error.displayCodeWithMessage("error_test_certificate_not_valid_message".localized),
                actions: [
                    DialogAction(
                        title: "error_test_certificate_not_valid_button_title".localized,
                        style: .cancel,
                        completion: { _ in completion?() }
                    )
                ],
                style: .alert
            )
        case let CertificateError.revoked(token):
            let title = "revocation_error_scan_title".localized
            let message = (
                token.vaccinationCertificate.isGermanIssuer ?
                "revocation_error_scan_single_DE" : "revocation_error_scan_single_notDE"
            ).localized
            let action = DialogAction(
                title: "error_test_certificate_not_valid_button_title".localized,
                style: .cancel,
                completion: { _ in completion?() }
            )

            showDialog(title: title, message: message, actions: [action], style: .alert)
        default:
            showDialog(
                title: "error_scan_qrcode_cannot_be_parsed_title".localized,
                message: error.displayCodeWithMessage("error_scan_qrcode_cannot_be_parsed_message".localized),
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
