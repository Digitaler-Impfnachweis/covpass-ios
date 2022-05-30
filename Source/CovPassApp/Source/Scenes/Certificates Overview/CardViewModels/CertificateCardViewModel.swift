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
    private var vaccinations: [Vaccination]
    private var recoveries: [Recovery]
    private var certificateIsFavorite: Bool
    private var onAction: (ExtendedCBORWebToken) -> Void
    private var onFavorite: (String) -> Void
    private var repository: VaccinationRepositoryProtocol
    private var boosterLogic: BoosterLogicProtocol
    private let currentDate: Date
    private lazy var dgc: DigitalGreenCertificate = certificate.hcert.dgc
    private lazy var certificate = token.vaccinationCertificate
    private lazy var isExpired = certificate.isExpired
    private lazy var isRecovery = certificate.isRecovery && !isInvalid
    private lazy var isBasicVaccination = dgc.fullImmunizationValid && !isBoosterVaccination && !isInvalid
    private lazy var isPartialVaccination = certificate.isVaccination && !dgc.fullImmunizationValid && !isInvalid
    private lazy var isBoosterVaccination = dgc .v?.first?.isBoosted(vaccinations: vaccinations, recoveries: recoveries) ?? false && !isInvalid
    private lazy var isPCRTest = dgc.isPCR && !isInvalid
    private lazy var isRapidAntigenTest = certificate.isTest && !isPCRTest && !isInvalid
    private lazy var isRevoked = token.isRevoked
    private lazy var tokenIsInvalid = token.isInvalid
    private lazy var partialVaccination: Vaccination? = {
        guard isPartialVaccination else { return nil }
        return dgc.v?.first
    }()
    // Show notification to the user if he is qualified for a booster vaccination
    var showBoosterAvailabilityNotification: Bool {
        guard let boosterCandidate = boosterLogic.checkCertificates([token]) else { return false }
        return boosterCandidate.state == .new
    }
    private let showNotificationIcon: Bool

    // MARK: - Lifecycle

    init(
        token: ExtendedCBORWebToken,
        vaccinations: [Vaccination],
        recoveries: [Recovery],
        isFavorite: Bool,
        showFavorite: Bool,
        showTitle: Bool,
        showAction: Bool,
        showNotificationIcon: Bool,
        onAction: @escaping (ExtendedCBORWebToken) -> Void,
        onFavorite: @escaping (String) -> Void,
        repository: VaccinationRepositoryProtocol,
        boosterLogic: BoosterLogicProtocol,
        currentDate: Date = Date()
    ) {
        self.token = token
        self.vaccinations = vaccinations
        self.recoveries = recoveries
        certificateIsFavorite = isFavorite
        self.showFavorite = showFavorite
        self.showTitle = showTitle
        self.showAction = showAction
        self.onAction = onAction
        self.onFavorite = onFavorite
        self.repository = repository
        self.boosterLogic = boosterLogic
        self.currentDate = currentDate
        self.showNotificationIcon = showNotificationIcon
    }

    // MARK: - Internal Properties

    var delegate: ViewModelDelegate?

    var reuseIdentifier: String {
        "\(CertificateCollectionViewCell.self)"
    }

    var backgroundColor: UIColor {
        isInvalid ? .onBackground40 : .onBrandAccent70
    }

    var iconTintColor: UIColor {
        isInvalid ? UIColor(hexString: "878787") : .onBrandAccent70
    }

    var textColor: UIColor {
        .neutralWhite
    }

    lazy var title: String = {
        let title: String
        if isInvalid {
            title = "startscreen_card_title"
        } else if isRecovery {
            title = "certificate_type_recovery"
        } else if isBasicVaccination {
            title = "certificate_type_basic_immunisation"
        } else if isBoosterVaccination {
            title = "certificate_type_booster"
        } else if isPCRTest {
            title = "certificates_overview_pcr_test_certificate_message"
        } else if isRapidAntigenTest {
            title = "certificates_overview_test_certificate_message"
        } else if let vaccination = partialVaccination {
            title = String(
                format: "certificates_overview_vaccination_certificate_message".localized,
                vaccination.dn,
                vaccination.sd
            )
        } else {
            title = ""
        }
        return title.localized
    }()

    lazy var subtitle: String = {
        let subtitle: String
        if isExpired {
            subtitle = "certificates_start_screen_qrcode_certificate_expired_subtitle".localized
        } else if isRecovery, let date = dgc.r?.first?.fr {
            subtitle = currentDate.monthSinceString(date)
        } else if isBasicVaccination || isPartialVaccination, let date = dgc.v?.first?.dt {
            subtitle = currentDate.monthSinceString(date)
        } else if isBoosterVaccination, let date = dgc.v?.first?.dt {
            subtitle = currentDate.daysSinceString(date)
        } else if isPCRTest || isRapidAntigenTest, let date = dgc.t?.first?.sc {
            subtitle = currentDate.hoursSinceString(date)
        } else if isRevoked || tokenIsInvalid {
            subtitle = "certificates_start_screen_qrcode_certificate_invalid_subtitle".localized
        } else if showBoosterAvailabilityNotification {
            subtitle = "vaccination_start_screen_qrcode_booster_vaccination_note_subtitle".localized
        } else {
            subtitle = ""
        }
        return subtitle
    }()

    var titleIcon: UIImage {
        if isInvalid {
            return .expired
        } else if isPCRTest || isRapidAntigenTest {
            return .detailStatusTestInverse
        } else if isPartialVaccination {
            return .startStatusPartial
        }
        return showBoosterAvailabilityNotification && showNotificationIcon ? .statusFullBlueNotification : .statusFullDetail
    }

    var isFavorite: Bool {
        certificateIsFavorite
    }

    lazy var isInvalid: Bool = isExpired || tokenIsInvalid || isRevoked

    var showFavorite: Bool = true
    var showTitle: Bool = false
    var showAction: Bool = false

    lazy var qrCode: UIImage? = {
        let code = isRevoked ? "" : token.vaccinationQRCodeData
        return code.generateQRCode()
    }()

    var name: String {
        dgc.nam.fullName
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
        onFavorite(dgc.uvci)
    }
}

private extension Date {
    func monthSinceString(_ date: Date) -> String {
        String(
            format: "certificate_timestamp_months".localized,
            monthsSince(date)
        )
    }

    func daysSinceString(_ date: Date) -> String {
        String(
            format: "certificate_timestamp_days".localized,
            daysSince(date)
        )
    }

    func hoursSinceString(_ date: Date) -> String {
        String(
            format: "certificate_timestamp_hours".localized,
            hoursSince(date)
        )
    }
}
