//
//  AppInformationViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import UIKit

class GermanAppInformationViewModel: AppInformationBaseViewModel {
    override var entries: [AppInformationEntry] {
        var entries = [
            AppInformationEntry(
                title: Texts.appInformationTitle,
                scene: TrustedListDetailsSceneFactory(sceneCoordinator: router.sceneCoordinator)
            )
        ]

        if nowNotPassedFirstOfJanuary2024 {
            entries.append(whatsNewEntry)
        }

        let faqURL = URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/")!
        entries.append(.webEntry(title: Texts.faqTitle,
                                 url: faqURL,
                                 openingAnnounce: Accessibility.Opening.faqTitle,
                                 closingAnnounce: Accessibility.Closing.faqTitle,
                                 rightImage: .externalLink))

        if nowNotPassedFirstOfJanuary2024 {
            entries.append(.webEntry(title: Texts.leichteSprache,
                                     url: URL(string: "https://digitaler-impfnachweis-app.de/webviews/leichte-sprache/covpassapp")!,
                                     openingAnnounce: Accessibility.Opening.leichteSprache,
                                     closingAnnounce: Accessibility.Closing.leichteSprache,
                                     rightImage: .externalLink))
        }

        entries.append(.webEntry(title: Texts.datenschutzTitle,
                                 url: mainBundle.url(forResource: "privacy-covpass-de", withExtension: "html")!,
                                 enableDynamicFonts: true,
                                 openingAnnounce: Accessibility.Opening.datenschutzTitle,
                                 closingAnnounce: Accessibility.Closing.datenschutzTitle))

        entries.append(AppInformationEntry(
            title: Texts.companyDetailsTitle,
            scene: ImprintSceneFactory()
        ))

        entries.append(.webEntry(title: Texts.openSourceLicenseTitle,
                                 url: licenseBundle.url(forResource: "license_de", withExtension: "html")!,
                                 enableDynamicFonts: true,
                                 openingAnnounce: Accessibility.Opening.openSourceLicenseTitle,
                                 closingAnnounce: Accessibility.Closing.openSourceLicenseTitle))

        if nowNotPassedFirstOfJanuary2024 {
            entries.append(.webEntry(title: Texts.accessibilityStatementTitle,
                                     url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/covpass-app-ios-barrierefreiheitserklaerung/")!,
                                     openingAnnounce: Accessibility.Opening.accessibilityStatementTitle,
                                     closingAnnounce: Accessibility.Closing.accessibilityStatementTitle,
                                     rightImage: .externalLink))
        }
        return entries
    }
}

class EnglishAppInformationViewModel: AppInformationBaseViewModel {
    override var entries: [AppInformationEntry] {
        var entries = [
            AppInformationEntry(
                title: Texts.appInformationTitle,
                scene: TrustedListDetailsSceneFactory(sceneCoordinator: router.sceneCoordinator)
            )
        ]

        if nowNotPassedFirstOfJanuary2024 {
            entries.append(whatsNewEntry)
        }

        let faqURL = URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/")!
        entries.append(.webEntry(title: Texts.faqTitle,
                                 url: faqURL,
                                 openingAnnounce: Accessibility.Opening.faqTitle,
                                 closingAnnounce: Accessibility.Closing.faqTitle,
                                 rightImage: .externalLink))

        entries.append(.webEntry(title: Texts.datenschutzTitle,
                                 url: mainBundle.url(forResource: "privacy-covpass-en", withExtension: "html")!,
                                 enableDynamicFonts: true,
                                 openingAnnounce: Accessibility.Opening.datenschutzTitle,
                                 closingAnnounce: Accessibility.Closing.datenschutzTitle))

        entries.append(AppInformationEntry(
            title: Texts.companyDetailsTitle,
            scene: ImprintSceneFactory()
        ))

        entries.append(.webEntry(title: Texts.openSourceLicenseTitle,
                                 url: licenseBundle.url(forResource: "license_en", withExtension: "html")!,
                                 enableDynamicFonts: true,
                                 openingAnnounce: Accessibility.Opening.openSourceLicenseTitle,
                                 closingAnnounce: Accessibility.Closing.openSourceLicenseTitle))

        if nowNotPassedFirstOfJanuary2024 {
            entries.append(.webEntry(title: Texts.accessibilityStatementTitle,
                                     url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/covpass-app-ios-accessibility-statement/")!,
                                     openingAnnounce: Accessibility.Opening.accessibilityStatementTitle,
                                     closingAnnounce: Accessibility.Closing.accessibilityStatementTitle,
                                     rightImage: .externalLink))
        }

        return entries
    }
}
