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
    private var boosterLogic: BoosterLogic
    private var certificate: DigitalGreenCertificate {
        token.vaccinationCertificate.hcert.dgc
    }
    // Show notification to the user if he is qualified for a booster vaccination
    private var showNotification: Bool {
        guard let boosterCandidate = boosterLogic.checkCertificates([token]) else { return false }
        return boosterCandidate.state == .new
    }

    // MARK: - Lifecycle

    init(
        token: ExtendedCBORWebToken,
        isFavorite: Bool,
        showFavorite: Bool,
        onAction: @escaping (ExtendedCBORWebToken) -> Void,
        onFavorite: @escaping (String) -> Void,
        repository: VaccinationRepositoryProtocol,
        boosterLogic: BoosterLogic
    ) {
        self.token = token
        certificateIsFavorite = isFavorite
        self.showFavorite = showFavorite
        self.onAction = onAction
        self.onFavorite = onFavorite
        self.repository = repository
        self.boosterLogic = boosterLogic
    }

    // MARK: - Internal Properties

    var delegate: ViewModelDelegate?

    var reuseIdentifier: String {
        "\(CertificateCollectionViewCell.self)"
    }

    var backgroundColor: UIColor {
        if token.vaccinationCertificate.isExpired || token.vaccinationCertificate.isInvalid {
            return .onBackground40
        }
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
        if token.vaccinationCertificate.isExpired {
            return "certificates_overview_expired_certificate_note".localized
        }
        if token.vaccinationCertificate.expiresSoon {
            guard let expireDate = token.vaccinationCertificate.exp else {
                return "certificates_overview_expires_soon_certificate_note".localized
            }
            return String(format: "certificates_start_screen_qrcode_certificate_expires_subtitle".localized,
                          DateUtils.displayDateFormatter.string(from: expireDate),
                          DateUtils.displayTimeFormatter.string(from: expireDate))
        }

        if token.vaccinationCertificate.isInvalid {
            return "certificates_overview_invalid_certificate_note".localized
        }
        if let r = certificate.r?.first {
            if Date() < r.df {
                return String(format: "certificates_overview_recovery_certificate_valid_from_date".localized, DateUtils.displayDateFormatter.string(from: r.df))
            }
            return String(format: "certificates_overview_recovery_certificate_valid_until_date".localized, DateUtils.displayDateFormatter.string(from: r.du))
        }
        if let t = certificate.t?.first {
            return DateUtils.displayDateTimeFormatter.string(from: t.sc)
        }
        if let v = certificate.v?.first {
            if v.fullImmunizationValid, showNotification {
                return "vaccination_start_screen_qrcode_booster_vaccination_note_subtitle".localized
            } else if v.fullImmunizationValid {
                return "vaccination_start_screen_qrcode_complete_protection_subtitle".localized
            } else if let date = v.fullImmunizationValidFrom, v.fullImmunization {
                return String(format: "vaccination_start_screen_qrcode_complete_from_date_subtitle".localized, DateUtils.displayDateFormatter.string(from: date))
            }

            return String(format: "vaccination_start_screen_qrcode_incomplete_subtitle".localized, 1, 2)
        }
        return ""
    }

    var titleIcon: UIImage {
        if token.vaccinationCertificate.isExpired {
            return UIImage.expired.withRenderingMode(.alwaysTemplate)
        }
        if token.vaccinationCertificate.expiresSoon {
            return UIImage.activity.withRenderingMode(.alwaysTemplate)
        }
        if certificate.r != nil {
            return UIImage.statusFullDetail.withRenderingMode(.alwaysTemplate)
        }
        if certificate.t != nil {
            return UIImage.iconTest.withRenderingMode(.alwaysTemplate)
        }
        if isFullImmunization, showNotification {
            return UIImage.statusFullNotfication.withRenderingMode(.alwaysOriginal) // !!!
        } else if isFullImmunization {
            return UIImage.statusFullDetail.withRenderingMode(.alwaysTemplate)
        } else {
            return UIImage.statusPartialDetail.withRenderingMode(.alwaysTemplate)
        }
    }

    var isFavorite: Bool {
        certificateIsFavorite
    }

    var isExpired: Bool {
        token.vaccinationCertificate.isExpired || token.vaccinationCertificate.isInvalid
    }

    var isBoosted: Bool {
        token.vaccinationCertificate.hcert.dgc.isVaccinationBoosted
    }

    // Hide favorite button if this certificate is the only card that is shown
    var showFavorite: Bool = true

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
        if token.vaccinationCertificate.isExpired || token.vaccinationCertificate.isInvalid {
            return .neutralWhite
        }
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
