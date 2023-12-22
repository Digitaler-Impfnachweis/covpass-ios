//
//  CertificateCardViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class CertificateOverviewCardViewModel: CertificateCardViewModelProtocol {
    // MARK: - Private Properties

    private var token: ExtendedCBORWebToken
    private var tokens: [ExtendedCBORWebToken]
    private var onAction: (ExtendedCBORWebToken) -> Void
    private var boosterLogic: BoosterLogicProtocol
    private var userDefaults: UserDefaultsPersistence
    private lazy var dgc: DigitalGreenCertificate = certificate.hcert.dgc
    private lazy var certificate = token.vaccinationCertificate
    private lazy var isExpired = certificate.isExpired
    private lazy var isRevoked = token.isRevoked
    private lazy var tokenIsInvalid = token.isInvalid
    private var anyCertExpiredMoreThan90Days: Bool {
        let certs = tokens.filterFirstOfAllTypes.map(\.vaccinationCertificate)
        return certs.map(\.expiredMoreThan90Days).contains(where: { $0 == true })
    }

    private var anyCertExpiredForLessOrEqual90Days: Bool {
        let certs = tokens.filterFirstOfAllTypes.map(\.vaccinationCertificate)
        return certs.map(\.expiredForLessOrEqual90Days).contains(where: { $0 == true })
    }

    private var anyCertWillExpireInLessOrEqual28Days: Bool {
        let certs = tokens.filterFirstOfAllTypes.map(\.vaccinationCertificate)
        return certs.map(\.willExpireInLessOrEqual28Days).contains(where: { $0 == true })
    }

    private var showBoosterAvailabilityNotification: Bool {
        guard let boosterCandidate = boosterLogic.checkCertificates([token]) else { return false }
        return boosterCandidate.state == .new
    }

    private var showNotificationForExpiryOrInvalid: Bool {
        let certs = tokens.filterFirstOfAllTypes.map(\.vaccinationCertificate)
        let anyCertPassed28DaysExpiry = certs.map(\.passed28DaysBeforeExpiration).contains(where: { $0 == true })
        return anyCertPassed28DaysExpiry || (token.isInvalid && token.expiryAlertWasNotShown)
    }

    // MARK: public properties

    var showNotification: Bool {
        showBoosterAvailabilityNotification || showNotificationForExpiryOrInvalid
    }

    var regionText: String? {
        guard !isInvalid else { return nil }
        let region = ("DE_" + userDefaults.stateSelection).localized
        let text = "infschg_start_screen_status_federal_state".localized
        return String(format: text, region)
    }

    // MARK: - Lifecycle

    init(
        token: ExtendedCBORWebToken,
        tokens: [ExtendedCBORWebToken],
        onAction: @escaping (ExtendedCBORWebToken) -> Void,
        repository _: VaccinationRepositoryProtocol,
        boosterLogic: BoosterLogicProtocol,
        userDefaults: UserDefaultsPersistence
    ) {
        self.token = token
        self.tokens = tokens
        self.onAction = onAction
        self.boosterLogic = boosterLogic
        self.userDefaults = userDefaults
    }

    // MARK: - Internal Properties

    var delegate: ViewModelDelegate?

    var reuseIdentifier: String {
        "\(CertificateOverviewCollectionViewCell.self)"
    }

    var backgroundColor: UIColor {
        isInvalid ? .onBackground40 : .onBrandAccent70
    }

    var iconTintColor: UIColor {
        isInvalid ? UIColor(hexString: "737373") : .onBrandAccent70
    }

    let textColor: UIColor = .neutralWhite

    let title: String = ""

    let subtitle: String = ""

    lazy var headerSubtitle: String? = {
        guard showNotification else {
            return nil
        }
        if anyCertExpiredMoreThan90Days {
            return "certificates_overview_expired_title".localized
        } else if anyCertExpiredForLessOrEqual90Days, !Date().passedFirstOfJanuary2024 {
            return "vaccination_start_screen_qrcode_renewal_note_subtitle".localized
        } else if anyCertWillExpireInLessOrEqual28Days, !Date().passedFirstOfJanuary2024 {
            return "vaccination_start_screen_qrcode_renewal_note_subtitle".localized
        } else if Date().passedFirstOfJanuary2024 {
            return nil
        } else {
            return "infschg_start_notification".localized
        }
    }()

    var titleIcon: UIImage {
        .init()
    }

    var subtitleIcon: UIImage {
        if isInvalid {
            return showNotification ? .expiredDotNotification : .statusInvalidCircle
        }
        return .iconRed
    }

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
        textColor
    }

    // MARK: - Actions

    func onClickAction() {
        onAction(token)
    }
}
