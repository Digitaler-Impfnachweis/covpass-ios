//
//  CertificateDetailViewModelMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import UIKit

final class CertificateDetailViewModelMock: CertificateDetailViewModelProtocol {
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
    var expiryReissueNotificationTitle = "Renewal needed"
    var vaccinationExpiryReissueNotificationBody = "The technical expiry date of your vaccination certificate is coming up. Renew the certificate to continue using it."
    var vaccinationExpiryReissueButtonTitle = "Renew vaccination certificate"
    var recoveryExpiryReissueNotificationBody = "The technical expiry date of your recovery certificate is coming up. Renew the certificate to continue using it."
    var recoveryExpiryReissueButtonTitle = "Renew recovery certificate"
    var showBoosterReissueNotification = false
    var showVaccinationExpiryReissueNotification = false
    var showBoosterReissueIsNewBadge = false
    var showVaccinationExpiryReissueIsNewBadge = false
    var recoveryExpiryReissueCandidatesCount: Int {
        showRecoveryExpiryReissueIsNewBadgeValues.count
    }
    var showRecoveryExpiryReissueIsNewBadgeValues: [Bool] = []
    func showRecoveryExpiryReissueIsNewBadge(index: Int) -> Bool {
        if index < showRecoveryExpiryReissueIsNewBadgeValues.count {
            return showRecoveryExpiryReissueIsNewBadgeValues[index]
        }
        return false
    }

    func triggerBoosterReissue() {}
    func triggerVaccinationExpiryReissue() {}
    func triggerRecoveryExpiryReissue(index: Int) {}
    func refresh() {}
    func immunizationButtonTapped() {}
    func toggleFavorite() {}
    func updateBoosterCandiate() {}
    func updateReissueCandidate(to value: Bool) {}
    func markExpiryReissueCandidatesAsSeen() {}
}
