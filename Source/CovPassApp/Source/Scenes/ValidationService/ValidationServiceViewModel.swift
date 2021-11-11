//
//  ValidationServiceViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

private enum Constants {
    enum Text {
        static let additionalInformation1 = "Sie sind nicht verpflichtet, die Überprüfung Ihres Zertifikats mit der CovPass-App zu erlauben. Der Nachweis Ihres Impf-, Test- oder Genesungsstatus kann auch auf andere Weise erbracht werden."
        static let additionalInformation2 = "Die Anforderungen an das Zertifikat werden vom Anbieter festgelegt. Das RKI hat darauf keinen Einfluss. Weitere Informationen zu den Zertifikatsanforderungen erhalten Sie bei dem Anbieter."
        static let additionalInformation3 = "Die Ermittlung der geeigneten Zertifikate erfolgt lokal auf Ihrem Smartphone. Es werden dabei keine Daten an das RKI oder den Anbieter übermittelt."
        static let additionalInformation4 = "Das RKI erfährt die Daten zu Ihrer Buchung oder den von Ihnen gespeicherten Zertifikaten nicht."
        static let additionalInformation5 = "Ausführliche Hinweise zur Datenverarbeitung finden Sie in der Datenschutzerklärung:"

        enum HintView {
            static let introText = "Durch Antippen von „Einverstanden“ willigen Sie in die folgenden Schritte ein:"
            static let bulletText1 = "Die App ruft vom Anbieter „Anbietername“ den Namen und das Geburtsdatum der bei Buchung angegebenen Person, die für die Prüfung relevanten Buchungsdetails (z. B. Zielland und Reisedatum) und die vom Anbieter zu Ihrer Buchung festgelegten Anforderungen an das Zertifikat ab."
            static let bulletText2 = "Die abgerufenen Daten werden von der App genutzt, um festzustellen, welche Ihrer gespeicherten Zertifikate verwendet werden können."
        }
    }
}

struct ValidationServiceViewModel {

    enum Rows: Int {
        case provider = 0, subject = 1, consentHeader = 2, hintView = 3, additionalInformation = 4, privacyLink = 5
    }

    let router: ValidationServiceRouter

    internal init(router: ValidationServiceRouter, initialisationData: ValidationServiceInitialisation) {
        self.router = router
        self.initialisationData = initialisationData
    }

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
            .appendBullets([Constants.Text.HintView.bulletText1.styledAs(.body), Constants.Text.HintView.bulletText2.styledAs(.body)], spacing: 12)
    }

    var numberOfSections: Int {
        1
    }

    var numberOfRows: Int {
        6
    }
}
