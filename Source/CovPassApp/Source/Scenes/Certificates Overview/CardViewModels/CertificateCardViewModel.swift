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
        if isExpired {
            return .onBackground40
        }
        return .onBrandAccent70
    }

    var iconTintColor: UIColor {
        return .neutralWhite
    }

    var textColor: UIColor {
        return .neutralWhite
    }

    var title: String {
        return "startscreen_card_title".localized
    }

    var subtitle: String {
        if isExpired {
            return "certificates_start_screen_qrcode_certificate_expired_subtitle".localized
        }
        if showNotification {
            return "vaccination_start_screen_qrcode_booster_vaccination_note_subtitle".localized
        }
        return ""
    }

    var titleIcon: UIImage {
        if isExpired {
            return UIImage.expired
        }
        return showNotification ? UIImage.statusFullNotfication : UIImage.statusFullDetail
    }

    var isFavorite: Bool {
        certificateIsFavorite
    }

    var isExpired: Bool {
        token.vaccinationCertificate.isExpired || token.vaccinationCertificate.isInvalid
    }

    var showFavorite: Bool = true

    var qrCode: UIImage? {
        return token.vaccinationQRCodeData.generateQRCode()
    }

    var name: String {
        certificate.nam.fullName
    }

    var actionTitle: String {
        "startscreen_card_button".localized
    }

    var tintColor: UIColor {
        return textColor
    }

    // MARK: - Actions

    func onClickAction() {
        onAction(token)
    }

    func onClickFavorite() {
        onFavorite(certificate.uvci)
    }
}
