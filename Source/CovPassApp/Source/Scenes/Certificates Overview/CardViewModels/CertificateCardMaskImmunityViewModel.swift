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

class CertificateCardMaskImmunityViewModel: CertificateCardViewModelProtocol {

   
    // MARK: - Private Properties

    private var token: ExtendedCBORWebToken
    private var tokens: [ExtendedCBORWebToken]
    private var onAction: (ExtendedCBORWebToken) -> Void
    private var boosterLogic: BoosterLogicProtocol
    private lazy var dgc: DigitalGreenCertificate = certificate.hcert.dgc
    private lazy var certificate = token.vaccinationCertificate
    private lazy var isExpired = certificate.isExpired
    private lazy var isRevoked = token.isRevoked
    private lazy var tokenIsInvalid = token.isInvalid
    private var showBoosterAvailabilityNotification: Bool {
        guard let boosterCandidate = boosterLogic.checkCertificates([token]) else { return false }
        return boosterCandidate.state == .new
    }
    private var showNotificationForExpiryOrInvalid: Bool {
        guard token.vaccinationCertificate.isNotTest else {
            return false
        }
        guard token.expiryAlertWasNotShown || !(token.reissueProcessNewBadgeAlreadySeen ?? false) else {
            return false
        }
        let cert = token.vaccinationCertificate
        return cert.expiresSoon || token.isInvalid || cert.isExpired
    }
    var showNotification: Bool {
        showBoosterAvailabilityNotification || showNotificationForExpiryOrInvalid
    }
    private let certificateHolderStatusModel: CertificateHolderStatusModelProtocol
    private var holderNeedsMask: Bool
    
    // MARK: - Lifecycle

    init(
        token: ExtendedCBORWebToken,
        tokens: [ExtendedCBORWebToken],
        onAction: @escaping (ExtendedCBORWebToken) -> Void,
        certificateHolderStatusModel: CertificateHolderStatusModelProtocol,
        repository: VaccinationRepositoryProtocol,
        boosterLogic: BoosterLogicProtocol
    ) {
        self.token = token
        self.tokens = tokens
        self.onAction = onAction
        self.holderNeedsMask = true
        self.boosterLogic = boosterLogic
        self.certificateHolderStatusModel = certificateHolderStatusModel
        updateCertificateHolderStatus()
    }
    
    func updateCertificateHolderStatus() {
        certificateHolderStatusModel
            .holderNeedsMaskAsync(self.tokens)
            .done { holderNeedsMask in
                self.holderNeedsMask = holderNeedsMask
                DispatchQueue.main.async {
                    self.delegate?.viewModelDidUpdate()
                }
            }
            .cauterize()
    }

    // MARK: - Internal Properties

    var delegate: ViewModelDelegate?

    var reuseIdentifier: String {
        "\(CertificateMaskImmunityCollectionViewCell.self)"
    }

    var backgroundColor: UIColor {
        if isInvalid {
            return .onBackground40
        } else if holderNeedsMask {
            return .onBrandAccent70
        } else  {
            return .brandAccent90
        }
    }

    var iconTintColor: UIColor {
        isInvalid ? UIColor(hexString: "878787") : .onBrandAccent70
    }

    let textColor: UIColor = .neutralWhite

    lazy var title: String = {
        if isInvalid {
            return "infschg_start_expired_revoked".localized
        } else if holderNeedsMask {
            return "infschg_start_mask_mandatory".localized
        }
        return "infschg_start_mask_optional".localized
    }()
    
    lazy var subtitle: String = {
        if isInvalid {
            return "infschg_start_expired_revoked".localized
        }
        return ""
    }()
    
    lazy var headerSubtitle: String? = {
        showNotification ? "infschg_start_notification".localized : nil
    }()

    var titleIcon: UIImage {
        if isInvalid {
            return .statusMaskInvalidCircle
        } else if holderNeedsMask {
            return .statusMaskRequiredCircle
        } else  {
            return .statusMaskOptionalCircle
        }
    }
    
    var subtitleIcon: UIImage {
        if isInvalid {
            return  showNotification ? .expiredDotNotification : .statusInvalidCircle
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
        return textColor
    }

    // MARK: - Actions

    func onClickAction() {
        onAction(token)
    }
}
