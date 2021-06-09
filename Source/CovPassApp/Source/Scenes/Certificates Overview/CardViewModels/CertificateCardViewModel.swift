//
//  CertificateCardViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

class CertificateCardViewModel: CertificateCardViewModelProtocol {
    // MARK: - Private Properties

    private var token: ExtendedCBORWebToken
    private var certificateIsFavorite: Bool
    private var onAction: (ExtendedCBORWebToken) -> Void
    private var onFavorite: (String) -> Void
    private var repository: VaccinationRepositoryProtocol
    private var didFailToUpdate: Bool = false
    private var certificate: DigitalGreenCertificate {
        token.vaccinationCertificate.hcert.dgc
    }

    // MARK: - Lifecycle

    init(token: ExtendedCBORWebToken, isFavorite: Bool, onAction: @escaping (ExtendedCBORWebToken) -> Void, onFavorite: @escaping (String) -> Void, repository: VaccinationRepositoryProtocol) {
        self.token = token
        certificateIsFavorite = isFavorite
        self.onAction = onAction
        self.onFavorite = onFavorite
        self.repository = repository
    }

    // MARK: - Internal Properties

    var delegate: ViewModelDelegate?

    var reuseIdentifier: String {
        "\(CertificateCollectionViewCell.self)"
    }

    var backgroundColor: UIColor {
        if certificate.r != nil {
            return .brandAccentBlue
        }
        if certificate.t != nil {
            return .brandAccentPurple
        }
        return certificate.v?.first?.fullImmunizationValid ?? false ? .onBrandAccent70 : .onBackground50
    }

    var title: String {
        if certificate.r != nil {
            return "certificates_overview_recovery_certificate_title".localized
        }
        if let t = certificate.t?.first {
            return t.isPCR ? "certificates_overview_pcr_test_certificate_message".localized : "certificates_overview_test_certificate_message".localized
        }
        return "certificates_overview_vaccination_certificate_title".localized
    }

    var subtitle: String {
        if let r = certificate.r?.first {
            if Date() < r.df {
                return String(format: "certificates_overview_recovery_certificate_valid_from_date".localized, DateUtils.displayDateFormatter.string(from: r.df))
            }
            return String(format: "certificates_overview_recovery_certificate_valid_until_date".localized, DateUtils.displayDateFormatter.string(from: r.du))
        }
        if let t = certificate.t?.first {
            return DateUtils.displayDateFormatter.string(from: t.sc)
        }
        if let v = certificate.v?.first {
            if !v.fullImmunization {
                return String(format: "vaccination_certificate_overview_incomplete_title".localized, 1, 2)
            }
            if v.fullImmunizationValid {
                return "vaccination_start_screen_qrcode_complete_protection_subtitle".localized
            } else if let date = v.fullImmunizationValidFrom, v.fullImmunization {
                return String(format: "vaccination_certificate_overview_complete_title".localized, DateUtils.displayDateFormatter.string(from: date))
            }

            return String(format: "vaccination_certificate_overview_incomplete_title".localized, 1, 2)
        }
        return ""
    }

    var titleIcon: UIImage {
        if certificate.r != nil {
            return .statusFullDetail
        }
        if certificate.t != nil {
            return .iconTest
        }
        return isFullImmunization ? .statusFullDetail : .statusPartialDetail
    }

    var isFavorite: Bool {
        certificateIsFavorite
    }

    var qrCode: UIImage? {
        return token.vaccinationQRCodeData.generateQRCode(size: UIScreen.main.bounds.size)
    }

    var name: String {
        certificate.nam.fullName
    }

    var actionTitle: String {
        "vaccination_full_immunization_action_button".localized
    }

    var tintColor: UIColor {
        if let v = certificate.v?.first, !v.fullImmunizationValid {
            return .darkText
        }
        return .neutralWhite
    }

    var isFullImmunization: Bool {
        certificate.v?.first?.fullImmunization ?? false
    }

    var vaccinationDate: Date? {
        certificate.v?.first?.dt
    }

    // MARK: - Actions

    func onClickAction() {
        onAction(token)
    }

    func onClickFavorite() {
        onFavorite(certificate.uvci)
    }
}
