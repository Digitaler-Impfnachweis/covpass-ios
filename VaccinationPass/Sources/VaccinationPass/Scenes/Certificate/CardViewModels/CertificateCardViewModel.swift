//
//  CertificateCardViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationCommon
import VaccinationUI

// TODO: implement this
let NO_INTERNET = false

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

        reissueCertificateIfNeeded()
    }

    func reissueCertificateIfNeeded() {
        guard token.validationQRCodeData == nil else { return }
        repository.reissueValidationCertificate(token)
            .done { [weak self] cert in
                self?.token = cert
            }
            .catch { [weak self] _ in
                self?.didFailToUpdate = true
            }
            .finally { [weak self] in
                self?.delegate?.viewModelDidUpdate()
            }
    }

    // MARK: - Internal Properties

    var delegate: ViewModelDelegate?

    var reuseIdentifier: String {
        "\(CertificateCollectionViewCell.self)"
    }

    var backgroundColor: UIColor {
        isFullImmunization ? .onBrandAccent70 : .onBackground50
    }

    var title: String {
        isFullImmunization ? "vaccination_full_immunization_title".localized : "vaccination_partial_immunization_title".localized
    }

    var isFavorite: Bool {
        certificateIsFavorite
    }

    var qrCode: UIImage? {
        if !certificate.fullImmunizationValid { return nil }
        return token.validationQRCodeData?.generateQRCode(size: UIScreen.main.bounds.size)
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

    var isLoading: Bool {
        isFullImmunization && token.validationQRCodeData == nil
    }

    var errorTitle: String? {
        if !isFullImmunization { return nil }
        if token.validationQRCodeData == nil || certificate.fullImmunizationValid { return nil }
        guard let date = certificate.fullImmunizationValidFrom else { return nil }
        let dateString = DateUtils.displayDateFormatter.string(from: date)
        return String(format: "vaccination_full_immunization_loading_message_14_days_title".localized, dateString)
    }

    var errorSubtitle: String? {
        if !isFullImmunization { return nil }
        if token.validationQRCodeData == nil {
            if NO_INTERNET {
                return "vaccination_full_immunization_loading_message_check_internet".localized
            }
            if didFailToUpdate {
                return "vaccination_full_immunization_loading_message_error".localized
            }
        } else {
            if !certificate.fullImmunizationValid {
                return "vaccination_full_immunization_loading_message_14_days_message".localized
            }
        }
        return nil
    }

    var tintColor: UIColor {
        isFullImmunization ? .neutralWhite : .darkText
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
