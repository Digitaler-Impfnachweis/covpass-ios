//
//  ValidationServiceViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import CovPassUI

private enum Constants {

    static let reuseIdentifier = "cell"
    static let reuseIdentifierHintCell = "hintCell"
    static let reuseIdentifierSubTitleCell = "subTitleCell"

    static let numberOfSections = 1

    enum Text {
        static let additionalInformation1 = "share_certificate_notes_first_list_item".localized
        static let additionalInformation2 = "share_certificate_notes_second_list_item".localized
        static let additionalInformation3 = "share_certificate_notes_third_list_item".localized
        static let additionalInformation4 = "share_certificate_notes_fourth_list_item".localized
        static let additionalInformation5 = "share_certificate_note_privacy_notice".localized

        enum HintView {
            static let title = "share_certificate_transmission_consent_title".localized
            static let introText = "share_certificate_consent_message".localized
            static let bulletText1 = "share_certificate_consent_first_list_item".localized
            static let bulletText2 = "share_certificate_consent_second_list_item".localized
        }

        enum Cell {
            static let providerTitle = "share_certificate_transmission_details_provider".localized
            static let subjectTitle = "share_certificate_transmission_details_booking".localized
        }
    }
}

struct ValidationServiceViewModel {

    enum Accessibility {
        static let close = VoiceOverOptions.Settings(label: "accessibility_share_certificate_label_close".localized)
        static let openViewController = VoiceOverOptions.Settings(label: "accessibility_share_certificate_announce".localized)
        static let closeViewController = VoiceOverOptions.Settings(label: "accessibility_share_certificate_closing_announce".localized)
    }

    enum Rows: Int, CaseIterable {
        case provider = 0, subject, consentHeader, hintView, additionalInformation, privacyLink

        var cellTitle: String {
            switch self {
            case .provider:
                return Constants.Text.Cell.providerTitle
            case .subject:
                return Constants.Text.Cell.subjectTitle
            case .hintView:
                return Constants.Text.HintView.title
            default:
                return ""
            }
        }

        var reuseIdentifier: String {
            switch self {
            case .provider, .subject:
                return Constants.reuseIdentifierSubTitleCell
            case .hintView:
                return Constants.reuseIdentifierHintCell
            default:
                return Constants.reuseIdentifier
            }
        }

    }

    let router: ValidationServiceRouter

    let initialisationData: ValidationServiceInitialisation

    var additionalInformation: NSAttributedString {
        let bullets = NSAttributedString().appendBullets([Constants.Text.additionalInformation1.styledAs(.body),
                                                          Constants.Text.additionalInformation2.styledAs(.body),
                                                          Constants.Text.additionalInformation3.styledAs(.body),
                                                          Constants.Text.additionalInformation4.styledAs(.body)],
                                                         spacing: nil)
        let attrString = NSMutableAttributedString(attributedString: bullets)

        attrString.append(NSAttributedString(string: "\n\n"))

        attrString.append(Constants.Text.additionalInformation5.styledAs(.body).colored(.onBackground70, in: nil))
        return attrString
    }

    var hintViewText: NSAttributedString {
        Constants.Text.HintView.introText.styledAs(.body)

            .appendBullets([String(format: Constants.Text.HintView.bulletText1, initialisationData.serviceProvider).styledAs(.body),
                            Constants.Text.HintView.bulletText2.styledAs(.body)], spacing: 12)
    }

    var numberOfSections: Int {
        Constants.numberOfSections
    }

    var numberOfRows: Int {
        Rows.allCases.count
    }

    internal init(router: ValidationServiceRouter, initialisationData: ValidationServiceInitialisation) {
        self.router = router
        self.initialisationData = initialisationData
    }

    func routeToPrivacyStatement() {
        router.routeToPrivacyStatement(url: initialisationData.privacyUrl)
    }
}
