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

class GermanAppInformationViewModel: AppInformationBaseViewModel {
    override var entries: [AppInformationEntry] {
        [
            AppInformationEntry(
                title: Texts.appInformationTitle,
                scene: TrustedListDetailsSceneFactory(sceneCoordinator: router.sceneCoordinator)
            ),
            whatsNewEntry,
            .webEntry(title: Texts.faqTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/")!,
                      openingAnnounce: Accessibility.Opening.faqTitle,
                      closingAnnounce: Accessibility.Closing.faqTitle),
            .webEntry(title: Texts.leichteSprache,
                      url: URL(string: "https://digitaler-impfnachweis-app.de/webviews/leichte-sprache/covpassapp")!,
                      openingAnnounce: Accessibility.Opening.leichteSprache,
                      closingAnnounce: Accessibility.Closing.leichteSprache),
            .webEntry(title: Texts.contactTitle,
                      url: mainBundle.url(forResource: "contact-covpass-de", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.contactTitle,
                      closingAnnounce: Accessibility.Closing.contactTitle),
            .webEntry(title: Texts.datenschutzTitle,
                      url: mainBundle.url(forResource: "privacy-covpass-de", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.datenschutzTitle,
                      closingAnnounce: Accessibility.Closing.datenschutzTitle),
            .webEntry(title: Texts.companyDetailsTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/imprint/")!,
                      openingAnnounce: Accessibility.Opening.companyDetailsTitle,
                      closingAnnounce: Accessibility.Closing.companyDetailsTitle),
            .webEntry(title: Texts.openSourceLicenseTitle,
                      url: licenseBundle.url(forResource: "license_de", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.openSourceLicenseTitle,
                      closingAnnounce: Accessibility.Closing.openSourceLicenseTitle),
            .webEntry(title: Texts.accessibilityStatementTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/covpass-app-ios-barrierefreiheitserklaerung/")!,
                      openingAnnounce: Accessibility.Opening.accessibilityStatementTitle,
                      closingAnnounce: Accessibility.Closing.accessibilityStatementTitle)
        ]
    }
}

class EnglishAppInformationViewModel: AppInformationBaseViewModel {
    override var entries: [AppInformationEntry] {
        [
            AppInformationEntry(
                title: Texts.appInformationTitle,
                scene: TrustedListDetailsSceneFactory(sceneCoordinator: router.sceneCoordinator)
            ),
            whatsNewEntry,
            .webEntry(title: Texts.faqTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/")!,
                      openingAnnounce: Accessibility.Opening.faqTitle,
                      closingAnnounce: Accessibility.Closing.faqTitle),
            .webEntry(title: Texts.contactTitle,
                      url: mainBundle.url(forResource: "contact-covpass-en", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.contactTitle,
                      closingAnnounce: Accessibility.Closing.contactTitle),
            .webEntry(title: Texts.datenschutzTitle,
                      url: mainBundle.url(forResource: "privacy-covpass-en", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.datenschutzTitle,
                      closingAnnounce: Accessibility.Closing.datenschutzTitle),
            .webEntry(title: Texts.companyDetailsTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/imprint/")!,
                      openingAnnounce: Accessibility.Opening.companyDetailsTitle,
                      closingAnnounce: Accessibility.Closing.companyDetailsTitle),
            .webEntry(title: Texts.openSourceLicenseTitle,
                      url: licenseBundle.url(forResource: "license_en", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.openSourceLicenseTitle,
                      closingAnnounce: Accessibility.Closing.openSourceLicenseTitle),
            .webEntry(title: Texts.accessibilityStatementTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/covpass-app-ios-accessibility-statement/")!,
                      openingAnnounce: Accessibility.Opening.accessibilityStatementTitle,
                      closingAnnounce: Accessibility.Closing.accessibilityStatementTitle)
        ]
    }
}
