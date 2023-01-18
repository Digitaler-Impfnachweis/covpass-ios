//
//  CertificateDetailViewModelMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

final class CertificateDetailViewModelMock: CertificateDetailViewModelProtocol {
    var immunizationStatusViewIsHidden: Bool = false
    var showVaccinationExpiryReissueButtonInNotification: Bool = true
    var recoveryExpiryCount: Int = 1
    var router: CertificateDetailRouterProtocol = CertificateDetailRouterMock()
    var delegate: ViewModelDelegate?
    var favoriteIcon: UIImage?
    var immunizationButton = ""
    var name = ""
    var nameReversed = ""
    var nameTransliterated = ""
    var birthDate = ""
    var immunizationIcon: UIImage?
    var immunizationTitle = ""
    var immunizationBody = ""
    var immunizationHeader = ""
    var items: [CertificateItem] = []
    var showBoosterNotification = false
    var showScanHint = false
    var showNewBoosterNotification = false
    var boosterNotificationTitle = ""
    var boosterNotificationBody = "Der Vorgang ist ganz unkompliziert und dauert nur wenige Minuten. Sie können die Erneuerung auch später in der Detailansicht Ihrer Zertifikate anstoßen."
    var boosterNotificationHighlightText = "New"
    var boosterReissueNotificationTitle = "Changes to your certificates"
    var boosterReissueNotificationBody = "The EU specifications for certain vaccination certificates have been changed. This certificate does not correspond to the current numbering. It is still valid. However, if it is a certificate for a booster vaccination, it will not be recognized as such when checked.\n\nTherefore we recommend requesting a new certificate with the number 2/1 directly free of charge via the app."
    var reissueNotificationHighlightText = "New"
    var boosterReissueButtonTitle = "Update"
    var reissueVaccinationTitle = "Renewal needed"
    var vaccinationExpiryReissueNotificationBody = "The technical expiry date of your vaccination certificate is coming up. Renew the certificate to continue using it."
    var vaccinationExpiryReissueButtonTitle = "Renew vaccination certificate"
    var recoveryExpiryReissueNotificationBody = "The technical expiry date of your recovery certificate is coming up. Renew the certificate to continue using it."
    var recoveryExpiryReissueButtonTitle = "Renew recovery certificate"
    var title = "Personal details"
    var nameTitle = "Name, Vorname / Name, first name"
    var nameTitleStandard = "Standardisierter Name, Vorname / Standardized name, first name"
    var dateOfBirth = "Geburtsdatum / Date of birth (YYYY-MM-DD)"
    var certificatesTitle = "Digitales EU Zertifikat"
    var accessibilityName = "Name, first name"
    var accessibilityNameStandard = "Standardized name, first name"
    var accessibilityDateOfBirth = "Date of birth (YYYY-MM-DD)"
    var accessibilityCertificatesTitle = "Digital EU Zertifikat"
    var showBoosterReissueNotification = false
    var showVaccinationExpiryReissueNotification = false
    var recoveryExpiryReissueCandidatesCount: Int {
        showRecoveryExpiryReissueIsNewBadgeValues.count
    }

    var showRecoveryExpiryReissueIsNewBadgeValues: [Bool] = []
    var accessibilityBackToStart: String = "backToStart"
    var immunizationStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol = CertificateHolderImmunizationStatusViewModelMock()
    var maskStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol = CertificateHolderImmunizationStatusViewModelMock()
    var immunizationDetailsHidden: Bool = false
    var maskFaqLink: String = "#Mehr Informationen::https://www.digitaler-impfnachweis-app.de/faq/#die-aktuell-h-ufigsten-fragen#"

    var showRecoveryExpiryReissueButtonInNotification: Bool = true

    func showRecoveryExpiryReissueIsNewBadge(index: Int) -> Bool {
        if index < showRecoveryExpiryReissueIsNewBadgeValues.count {
            return showRecoveryExpiryReissueIsNewBadgeValues[index]
        }
        return false
    }

    func triggerBoosterReissue() {}
    func triggerVaccinationExpiryReissue() {}
    func triggerRecoveryExpiryReissue(index _: Int) {}
    func refresh() {}
    func immunizationButtonTapped() {}
    func toggleFavorite() {}
    func updateBoosterCandiate() {}
    func updateReissueCandidate(to _: Bool) {}
    func markExpiryReissueCandidatesAsSeen() {}
    func showStateSelection() {}
    func reissueRecoveryTitle(index: Int) -> String {
        "Recovery Reissue Title for Element No. \(index)"
    }

    func recoveryExpiryReissueNotificationBody(index: Int) -> String {
        "Recovery Reissue Body for Element No. \(index)"
    }

    func showRecoveryExpiryReissueButtonInNotification(index _: Int) -> Bool {
        showRecoveryExpiryReissueButtonInNotification
    }
}
