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

class GermanAppInformationViewModel: CovPassAppInformationViewModel {
    private let mainBundle: Bundle
    private let licenseBundle: Bundle

    override var entries: [AppInformationEntry] {
        [
            AppInformationEntry(
                title: Texts.federalStateTitle,
                scene: FederalStateSettingsSceneFactory(sceneCoordinator: router.sceneCoordinator),
                rightTitle: persistence.stateSelection.isEmpty ? "" : "DE_\(persistence.stateSelection)".localized
            ),
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

    init(
        router: AppInformationRouterProtocol,
        mainBundle: Bundle = .main,
        licenseBundle: Bundle = .commonBundle,
        persistence: Persistence
    ) {
        self.mainBundle = mainBundle
        self.licenseBundle = licenseBundle
        super.init(router: router, persistence: persistence)
    }
}

class EnglishAppInformationViewModel: CovPassAppInformationViewModel {
    private let mainBundle: Bundle
    private let licenseBundle: Bundle

    override var entries: [AppInformationEntry] {
        [
            AppInformationEntry(
                title: Texts.federalStateTitle,
                scene: FederalStateSettingsSceneFactory(sceneCoordinator: router.sceneCoordinator),
                rightTitle: persistence.stateSelection.isEmpty ? "" : "DE_\(persistence.stateSelection)".localized
            ),
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

    init(
        router: AppInformationRouterProtocol,
        mainBundle: Bundle = .main,
        licenseBundle: Bundle = .commonBundle,
        persistence: Persistence
    ) {
        self.mainBundle = mainBundle
        self.licenseBundle = licenseBundle
        super.init(router: router, persistence: persistence)
    }
}

private extension AppInformationEntry {
    static func webEntry(title: String,
                         url: URL,
                         enableDynamicFonts: Bool = false,
                         openingAnnounce: String,
                         closingAnnounce: String) -> AppInformationEntry {
        .init(
            title: title,
            scene: WebviewSceneFactory(title: title,
                                       url: url,
                                       enableDynamicFonts: enableDynamicFonts,
                                       openingAnnounce: openingAnnounce,
                                       closingAnnounce: closingAnnounce)
        )
    }
}
