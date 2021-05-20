//
//  CertificateCardViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassCommon
import CovPassUI

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
        certificate.fullImmunizationValid ? .onBrandAccent70 : .onBackground50
    }

    var title: String {
        isFullImmunization ? "vaccination_full_immunization_title".localized : "vaccination_partial_immunization_title".localized
    }

    var isFavorite: Bool {
        certificateIsFavorite
    }

    var qrCode: UIImage? {
        return token.vaccinationQRCodeData.generateQRCode(size: UIScreen.main.bounds.size)
    }

    var qrCodeTitle: String? {
        if certificate.fullImmunizationValid {
            return "vaccination_certificate_detail_view_complete_title".localized
        }
        if certificate.fullImmunization {
            return ""
        }
        return nil
    }

    var name: String {
        certificate.nam.fullName
    }

    var actionTitle: String {
        isFullImmunization ? "vaccination_full_immunization_action_button".localized : "vaccination_partial_immunization_action_button".localized
    }

    var actionImage: UIImage {
        isFullImmunization ? .completness : .halfShield
    }

    var tintColor: UIColor {
        certificate.fullImmunizationValid ? .neutralWhite : .darkText
    }

    var isFullImmunization: Bool {
        certificate.v.first?.fullImmunization ?? false
    }

    var vaccinationDate: Date? {
        certificate.v.first?.dt
    }

    // MARK: - Actions

    func onClickAction() {
        onAction(token)
    }

    func onClickFavorite() {
        guard let id = certificate.v.first?.ci else { return }
        onFavorite(id)
    }
}
