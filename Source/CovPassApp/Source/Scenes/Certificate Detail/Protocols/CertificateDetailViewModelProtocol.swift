//
//  CertificateDetailViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

protocol CertificateDetailViewModelProtocol {
    var router: CertificateDetailRouterProtocol { get set }
    var delegate: ViewModelDelegate? { get set }
    var favoriteIcon: UIImage? { get }
    var accessibilityBackToStart: String { get }
    var immunizationButton: String { get }
    var name: String { get }
    var nameReversed: String { get }
    var nameTransliterated: String { get }
    var birthDate: String { get }
    var immunizationIcon: UIImage? { get }
    var immunizationTitle: String { get }
    var immunizationBody: String { get }
    var immunizationHeader: String { get }
    var title: String { get }
    var nameTitle: String { get }
    var nameTitleStandard: String { get }
    var dateOfBirth: String { get }
    var certificatesTitle: String { get }
    var accessibilityName: String { get }
    var accessibilityNameStandard: String { get }
    var accessibilityDateOfBirth: String { get }
    var accessibilityCertificatesTitle: String { get }
    var items: [CertificateItem] { get }
    var showBoosterNotification: Bool { get }
    var showScanHint: Bool { get }
    var showNewBoosterNotification: Bool { get }
    var boosterNotificationTitle: String { get }
    var boosterNotificationBody: String { get }
    var boosterNotificationHighlightText: String { get }
    var boosterReissueNotificationTitle: String { get }
    var boosterReissueNotificationBody: String { get }
    var boosterReissueButtonTitle: String { get }
    var reissueVaccinationTitle: String { get }
    var vaccinationExpiryReissueNotificationBody: String { get }
    var vaccinationExpiryReissueButtonTitle: String { get }
    var recoveryExpiryReissueButtonTitle: String { get }
    var showBoosterReissueNotification: Bool { get }
    var showVaccinationExpiryReissueNotification: Bool { get }
    var showVaccinationExpiryReissueButtonInNotification: Bool { get }
    var recoveryExpiryReissueCandidatesCount: Int { get }
    var immunizationDetailsHidden: Bool { get }
    var immunizationStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol { get }
    var immunizationStatusViewIsHidden: Bool { get }
    var maskStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol { get }
    func reissueRecoveryTitle(index: Int) -> String
    func recoveryExpiryReissueNotificationBody(index: Int) -> String
    func showRecoveryExpiryReissueButtonInNotification(index: Int) -> Bool
    func triggerBoosterReissue()
    func triggerVaccinationExpiryReissue()
    func triggerRecoveryExpiryReissue(index: Int)
    func refresh()
    func immunizationButtonTapped()
    func toggleFavorite()
    func updateBoosterCandiate()
    func updateReissueCandidate(to value: Bool)
    func showStateSelection()
}
