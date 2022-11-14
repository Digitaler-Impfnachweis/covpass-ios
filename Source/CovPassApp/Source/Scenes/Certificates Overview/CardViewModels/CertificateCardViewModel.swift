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
    private var onAction: (ExtendedCBORWebToken) -> Void
    private var repository: VaccinationRepositoryProtocol
    private var boosterLogic: BoosterLogicProtocol
    private let currentDate: Date
    private lazy var dgc: DigitalGreenCertificate = certificate.hcert.dgc
    private lazy var certificate = token.vaccinationCertificate
    private lazy var isExpired = certificate.isExpired
    private lazy var isRecovery = certificate.isRecovery && !isInvalid
    private lazy var isPartialVaccination = certificate.isVaccination && !dgc.fullImmunizationValid && !isInvalid
    private lazy var isPCRTest = dgc.isPCR && !isInvalid
    private lazy var isRapidAntigenTest = certificate.isTest && !isPCRTest && !isInvalid
    private lazy var isRevoked = token.isRevoked
    private lazy var tokenIsInvalid = token.isInvalid
    private lazy var vaccination: Vaccination? = {
        return dgc.v?.first
    }()
    // Show notification to the user if he is qualified for a booster vaccination
    private var showBoosterAvailabilityNotification: Bool {
        guard let boosterCandidate = boosterLogic.checkCertificates([token]) else { return false }
        return boosterCandidate.state == .new
    }
    private var showNotificationForExpiryOrInvalid: Bool {
        guard token.vaccinationCertificate.isNotTest else {
            return false
        }
        let cert = token.vaccinationCertificate
        let reissueDetailsNotAlreadySeen = !(token.reissueProcessNewBadgeAlreadySeen ?? false)
        let reissueNotificationNotAlreadySeen = (reissueDetailsNotAlreadySeen && cert.expiredForLessOrEqual90Days)
        guard token.expiryAlertWasNotShown || reissueNotificationNotAlreadySeen else {
            return false
        }
        return cert.expiresSoon || token.isInvalid || cert.isExpired
    }
    private var holderNeedsMask: Bool
    var showNotification: Bool {
        showBoosterAvailabilityNotification || showNotificationForExpiryOrInvalid
    }
    var maskStatusIsHidden: Bool = true
    var regionText: String? = nil

    // MARK: - Lifecycle

    init(
        token: ExtendedCBORWebToken,
        holderNeedsMask: Bool,
        onAction: @escaping (ExtendedCBORWebToken) -> Void,
        repository: VaccinationRepositoryProtocol,
        boosterLogic: BoosterLogicProtocol,
        currentDate: Date = Date()
    ) {
        self.token = token
        self.holderNeedsMask = holderNeedsMask
        self.onAction = onAction
        self.repository = repository
        self.boosterLogic = boosterLogic
        self.currentDate = currentDate
    }

    // MARK: - Internal Properties

    var delegate: ViewModelDelegate?

    var reuseIdentifier: String {
        "\(CertificateCollectionViewCell.self)"
    }

    let backgroundColor: UIColor = .clear

    var iconTintColor: UIColor {
        isInvalid ? UIColor(hexString: "737373") : .onBrandAccent70
    }

    var textColor: UIColor {
        holderNeedsMask ? .onBrandAccent70 : .brandAccent90
    }

    lazy var title: String = {
        let title: String
        if isInvalid {
            title = "startscreen_card_title"
        } else if isRecovery {
            title = "certificate_type_recovery"
        } else if isPCRTest {
            title = "certificates_overview_pcr_test_certificate_message"
        } else if isRapidAntigenTest {
            title = "certificates_overview_test_certificate_message"
        } else if let vaccination = vaccination {
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
        } else if isPCRTest || isRapidAntigenTest, let date = dgc.t?.first?.sc {
            subtitle = currentDate.hoursSinceString(date)
        } else if isRevoked || tokenIsInvalid {
            subtitle = "certificates_start_screen_qrcode_certificate_invalid_subtitle".localized
        } else if certificate.isVaccination,
                  let date = dgc.v?.first?.dt {
            subtitle = currentDate.monthSinceString(date)
        } else if showBoosterAvailabilityNotification {
            subtitle = "vaccination_start_screen_qrcode_booster_vaccination_note_subtitle".localized
        } else {
            subtitle = ""
        }
        return subtitle
    }()
    
    
    var headerSubtitle: String? = nil

    var titleIcon: UIImage {
        if isInvalid {
            return .expired
        } else if isPCRTest || isRapidAntigenTest {
            return holderNeedsMask ? .detailStatusTestInverse : .statusTestNegative
        } else if isPartialVaccination {
            return holderNeedsMask ? .startStatusPartial : .statusFullGreen
        }
        return holderNeedsMask ? .statusFullDetail : .statusFullGreen
    }
    
    var subtitleIcon: UIImage = .init()

    lazy var isInvalid: Bool = isExpired || tokenIsInvalid || isRevoked

    var showFavorite: Bool = true

    lazy var qrCode: UIImage? = {
        let code = isInvalid ? "" : token.vaccinationQRCodeData
        return code.generateQRCode()
    }()

    var name: String {
        dgc.nam.fullName
    }

    var tintColor: UIColor {
        return textColor
    }

    // MARK: - Actions

    func onClickAction() {
        onAction(token)
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
