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
            .webEntry(title: Texts.leichteSprache,
                      url: URL(string: "https://digitaler-impfnachweis-app.de/webviews/leichte-sprache/covpassapp")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.leichteSprache),
            .webEntry(title: Texts.contactTitle,
                      url: mainBundle.url(forResource: "contact-covpass-de", withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.contactTitle),
            .webEntry(title: Texts.faqTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.faqTitle),
            .webEntry(title: Texts.datenschutzTitle,
                      url: mainBundle.url(forResource: "privacy-covpass-de", withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.datenschutzTitle),
            .webEntry(title: Texts.companyDetailsTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/imprint/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.companyDetailsTitle),
            .webEntry(title: Texts.openSourceLicenseTitle,
                      url: licenseBundle.url(forResource: "license_de", withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.openSourceLicenseTitle),
            .webEntry(title: Texts.accessibilityStatementTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/covpass-app-ios-barrierefreiheitserklaerung/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.accessibilityStatementTitle),
            AppInformationEntry(
                title: Texts.appInformationTitle,
                scene: TrustedListDetailsSceneFactory(sceneCoordinator: router.sceneCoordinator)
            ),
            whatsNewEntry,
            AppInformationEntry(
                title: Texts.federalStateTitle,
                scene: FederalStateSettingsSceneFactory(sceneCoordinator: router.sceneCoordinator),
                rightTitle: persistence.stateSelection.isEmpty ? "" : "DE_\(persistence.stateSelection)".localized
            ),
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
            .webEntry(title: Texts.contactTitle,
                      url: mainBundle.url(forResource: "contact-covpass-en", withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.contactTitle),
            .webEntry(title: Texts.faqTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.faqTitle),
            .webEntry(title: Texts.datenschutzTitle,
                      url: mainBundle.url(forResource: "privacy-covpass-en", withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.datenschutzTitle),
            .webEntry(title: Texts.companyDetailsTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/imprint/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.companyDetailsTitle),
            .webEntry(title: Texts.openSourceLicenseTitle,
                      url: licenseBundle.url(forResource: "license_en", withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.openSourceLicenseTitle),
            .webEntry(title: Texts.accessibilityStatementTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/covpass-app-ios-accessibility-statement/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.accessibilityStatementTitle),
            AppInformationEntry(
                title: Texts.appInformationTitle,
                scene: TrustedListDetailsSceneFactory(sceneCoordinator: router.sceneCoordinator)
            ),
            whatsNewEntry,
            AppInformationEntry(
                title: Texts.federalStateTitle,
                scene: FederalStateSettingsSceneFactory(sceneCoordinator: router.sceneCoordinator),
                rightTitle: persistence.stateSelection.isEmpty ? "" : "DE_\(persistence.stateSelection)".localized
            ),
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
                         accessibilityAnnouncement: String) -> AppInformationEntry {
        .init(
            title: title,
            scene: WebviewSceneFactory(title: title,
                                       url: url,
                                       accessibilityAnnouncement: accessibilityAnnouncement)
        )
    }
}
