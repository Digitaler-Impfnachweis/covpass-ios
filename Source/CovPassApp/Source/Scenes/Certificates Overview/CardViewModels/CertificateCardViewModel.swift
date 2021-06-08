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
            return .onBrandAccent70
        }
        if certificate.t != nil {
            return .onBrandAccent70
        }
        return certificate.v?.first?.fullImmunizationValid ?? false ? .onBrandAccent70 : .onBackground50
    }

    var title: String {
        "Impfzertifikat" // TODO change after decision
//        isFullImmunization ? "vaccination_full_immunization_title".localized : "vaccination_partial_immunization_title".localized
    }

    var subtitle: String {
        "24.05.2021, 12:12" // TODO change after decision
    }

    var titleIcon: UIImage {
        isFullImmunization ? .completness : .halfShield // TODO change after decision
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
        isFullImmunization ? "vaccination_full_immunization_action_button".localized : "vaccination_partial_immunization_action_button".localized // TODO change after decision
    }

    var tintColor: UIColor {
        return .white // TODO change after decision
//        certificate.fullImmunizationValid ? .neutralWhite : .darkText
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
        guard let id = certificate.v?.first?.ci else { return }
        onFavorite(id)
    }
}
